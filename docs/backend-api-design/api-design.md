# Shiftley API Design Document

## The Philosophy of Bulletproof API Design

Building an enterprise-grade backend is not just about making things work; it is about establishing a contract. The API design acts as the universal language between our servers, our mobile applications, and potentially third-party integrators. This section outlines the non-negotiable standards and the philosophy behind them.

### 1. The Anatomy of a Resource (Nouns, Plurals, and Nesting)
When designing paths, we are defining **resources**, not actions. The HTTP protocol already provides the "verbs" (`GET`, `POST`, `DELETE`). Therefore, our paths must strictly use **Nouns**.
*   **Plurals Everywhere:** We consistently use plural nouns. For example, `/api/v1/gigs` instead of `/api/v1/gig`. *Why?* Because a `GET` request retrieves a collection (a list of gigs), while `GET /gigs/123` retrieves a specific item from that collection. Mixing singular and plural creates cognitive friction for developers.
*   **Sensible Nesting:** When a resource belongs to another, we nest it logically: `/api/v1/employers/123/gigs`. However, **we never nest deeper than one level**. Deeply nested paths (e.g., `/employers/123/gigs/456/applications/789`) become brittle and hard to maintain. Once you have a unique ID for a gig, you can simply call `/gigs/456/applications`.

### 2. API Versioning 
Software evolves, but mobile apps don't update immediately. If we change the structure of a response, old versions of our app will crash.
*   **The Standard:** We use URL path versioning (`/api/v1/...`).
*   **Why?** It is explicit, cache-friendly, and simple to route at the load balancer level. When we make a breaking change three years from now, we will introduce `/api/v2/...` alongside `v1`, ensuring legacy clients remain completely undisturbed.

### 3. Predictable Payloads & Error Handling
A backend should never surprise the frontend. Every single response—whether a glorious success or a catastrophic failure—must adhere to a predictable wrapper schema.

#### The Success Wrapper & Implementation
Even if we are just returning a single string, we wrap it in a standardized JSON envelope. 

**How to implement it:**
In the Go backend, we create a centralized response utility function (e.g., `RespondSuccess(c *gin.Context, data interface{}, meta interface{})`). No API handler should ever call `c.JSON()` directly with raw, unformatted maps.
```json
{
  "success": true,
  "data": { "id": "V1StGXR8", "name": "Gig" },
  "meta": { "cursor": "next_nano_id", "has_more": true }
}
```
*Why over raw JSON?* Returning raw objects (`{"id": "123"}`) makes it extremely difficult to add metadata later. A wrapped response ensures we always have a standardized place for global flags (`success`), context, and pagination details (`meta`) without polluting the actual resource payload (`data`).

#### The Failure Contract and HTTP Codes
We do not just say "Error". Providing detailed, standardized error responses prevents hours of debugging for frontend teams.
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "The provided phone number is invalid.",
    "details": ["phone_number must contain exactly 10 digits"]
  }
}
```
Crucially, these JSON errors are paired with accurate **HTTP Status Codes**. We don't return an error message with a `200 OK` status.
*   `201 Created`: When a user or gig is successfully made.
*   `400 Bad Request`: When the frontend sends malformed data.
*   `401 Unauthorized`: When a token is missing or expired.
*   `403 Forbidden`: When a worker tries to delete an employer's gig.
*   `404 Not Found`: When a requested resource simply doesn't exist.
*   `500 Internal Server Error`: When something crashes on our side.

### 4. Security: Identifiers & Headers
*   **NanoIDs/UUIDs over Sequential Integers:** Auto-incrementing IDs (`/users/123`) allow malicious actors to scrape the entire database by simply counting up. All exposed resources use URL-safe NanoIDs (`/users/V1StGXR8`). They are mathematically virtually impossible to guess, adding a massive layer of security (preventing IDOR attacks), and stopping competitors from deducing platform growth metrics.
*   **Headers & Authorization:** Auth state is managed via short-lived JWTs (JSON Web Tokens) passed entirely via the standard `Authorization: Bearer <token>` header. We do not rely on cookies or query parameters for auth, ensuring seamless mobile compatibility.
*   **Idempotency Headers:** Network connectivity in the gig economy can be unstable. For all state-mutating transactional endpoints (like Payments or Escrows), the client must send an `Idempotency-Key` header (e.g., a specific NanoID generated on the mobile app before the user clicks 'Pay').
    *   **How to implement it:** We use our Redis cache layer as an Idempotency Store. When a `POST` request hits the server, a middleware intercepts the `Idempotency-Key`.
        1. If exactly the same key exists in Redis and `status == processing`, drop the duplicate request to prevent database race conditions.
        2. If the key exists and `status == complete`, return the cached HTTP response instantly without touching the primary database or external APIs.
        3. If the key does not exist, let the request proceed to the handler, process it, and store the final response object in Redis under that key with a TTL (e.g., 24 hours).
    *   *Why over simple POSTs:* This guarantees that if a user clicks "Pay" twice due to lag, or the network retries the request, the backend will process the charge exactly *once*.

### 5. Architectural Paradigms
#### Pagination Strategy
*   **Cursor-Based Pagination** (`?cursor=nano123&limit=20`) is used for high-throughput, rapidly changing data like Gig Feeds. *Why?* Massive datasets experience deep-page degradation with traditional `OFFSET` (the database has to physically scan and skip thousands of rows). Cursor pagination uses index scanning, meaning fetching page 10,000 is exactly as fast as fetching page 1.
*   **Offset/Limit** (`?page=1&limit=20`) is strictly reserved for small, isolated lists (like an employer looking at their own profile history).

#### Rate Limiting
APIs are open doors. IP-based and Context-based rate limits are applied globally. Without them, automated bots can spam the OTP mapping endpoints resulting in astronomical SMS gateway bills within minutes, or execute DoS attacks.

---

## Module 1: User Registration & Onboarding

Shiftley features 8 distinct roles. Registration is split into **Public** (Employers & Employees) and **Internal** (Staff managed by HR/Admins).

### 1. Public Registration Flow

Public users must verify their identity first using a 100% passwordless OTP flow via Phone or Email, then submit their profile documentation via `multipart/form-data`.

#### 1.1 Request OTP
Sends a 6-digit verification code to the user's phone or email address.

**Endpoint:** `POST /api/v1/auth/otp/send`
**Rate Limit:** Max 5 requests per hour per IP/Identifier.

**Request Body:**
```json
{
  "identifier": "+919876543210", 
  "type": "PHONE", 
  "role": "EMPLOYER" 
}
```
*(Note: `identifier` can be an email address if `type` is "EMAIL". The UI asks for the role first. We pass it here so the backend can track the intent for new signups).*

**Responses:**
*   `200 OK`: OTP sent successfully.

#### 1.2 Verify OTP (The Login Endpoint)
Verifies the 6-digit code. This endpoint acts as the universal **Login** for public users.

**Endpoint:** `POST /api/v1/auth/otp/verify`
**Rate Limit:** Max 5 incorrect attempts locks the identifier for 15 minutes.

**Request Body:**
```json
{
  "identifier": "+919876543210",
  "type": "PHONE",
  "code": "123456"
}
```

**Responses:**
*   `200 OK (New User)`: Returns a temporary Registration Token. The UI must route them to the Onboarding forms.
```json
{
  "success": true,
  "data": {
    "is_new_user": true,
    "registration_token": "temp_jwt_abc123"
  }
}
```
*   `200 OK (Returning User)`: Returns their profile and their primary Session JWT. The UI logs them in and routes to the dashboard.
```json
{
  "success": true,
  "data": {
    "is_new_user": false,
    "session_token": "primary_jwt_xyz789",
    "user": { "id": "nano123", "role": "EMPLOYER", "kyc_status": "VERIFIED" }
  }
}
```
*   `400 Bad Request`: "Invalid or expired OTP."

#### 1.3 Onboard Employer (Multipart Form)
Finalizes the Employer account creation. Due to heavy file uploads, this endpoint explicitly consumes `multipart/form-data`.

**Endpoint:** `POST /api/v1/onboarding/employer`
**Headers:** `Authorization: Bearer <registration_token>`
**Content-Type:** `multipart/form-data`

**Form Data Fields:**
*   `full_name` (Text)
*   `business_name` (Text)
*   `business_type` (Text)
*   `location` (Text - JSON string of latitude/longitude `{"lat": 17.68, "lng": 83.21}`)
*   `business_address` (Text)
*   `gst_number` (Text, Optional)
*   `email` (Text)
*   `business_phone_number` (Text)
*   `employer_phone_number` (Text - Usually matches the OTP phone)
*   `aadhaar_number` (Text - strictly 12 digits, backend matches/validates via API, only stores last 4)
*   `aadhaar_pdf` (File - Max 5MB, PDF/JPG/PNG. The masked version.)
*   `business_photo_1` (File - Max 5MB)
*   `business_photo_2` (File - Max 5MB)
*   `business_photo_3` (File - Max 5MB)

**Responses:**
*   `201 Created`: Account successfully created. Returns the primary Session JWT.
```json
{
  "success": true,
  "data": {
    "session_token": "primary_jwt_xyz789",
    "user": { "id": "nano123", "role": "EMPLOYER", "kyc_status": "PENDING" }
  }
}
```
*   `400 Bad Request`: Missing required files or invalid data payloads.
*   `413 Payload Too Large`: Total file size exceeds limits (e.g., > 15MB combined).

#### 1.4 Onboard Employee (Multipart Form)
Finalizes the Employee account creation.

**Endpoint:** `POST /api/v1/onboarding/employee`
**Headers:** `Authorization: Bearer <registration_token>`
**Content-Type:** `multipart/form-data`

**Form Data Fields:**
*   `full_name` (Text)
*   `email` (Text)
*   `phone_number` (Text)
*   `skill_ids` (Text - JSON array of NanoIDs representing specific skills, e.g., `["nano_waiter", "nano_delivery"]`)
*   `degree` (Text, Optional - e.g., "B.Sc Culinary Arts")
*   `specialization` (Text, Optional - e.g., "Pastry Chef")
*   `passing_year` (Integer, Optional - e.g., 2022)
*   `aadhaar_pdf` (File - Max 5MB, PDF/JPG. Masked version.)
*   `profile_picture` (File - Professional formal photo)

**Responses:**
*   `201 Created`: Account successfully created. Returns the primary Session JWT.

---

### 2. Internal Registration Flow

Internal roles (`VERIFIER`, `PRODUCT_ENGINEER`, `DATA_ANALYTICS`, `CUSTOMER_SERVICE`) bypass OTP entirely. They are created exclusively by `SUPER_ADMIN` or `HR_ADMIN`.

#### 2.1 Invite Internal Staff
Creates an internal account and triggers an email with a secure, temporary password to the new staff member.

**Endpoint:** `POST /api/v1/admin/users/invite`
**Headers:** `Authorization: Bearer <admin_or_hr_jwt>`

**Request Body:**
```json
{
  "full_name": "Anita Desai",
  "email": "anita.d@shiftley.in",
  "phone_number": "+919876543211",
  "aadhaar_number": "123456789012",
  "role": "VERIFIER"
}
```
*(The backend securely stores the last 4 digits of Aadhaar via API integration and provisions the account).*

**Responses:**
*   `201 Created`: Account successfully generated, credentials emailed.
```json
{
  "success": true,
  "data": {
    "id": "nano456",
    "message": "User VERIFIER created. Login credentials sent to anita.d@shiftley.in"
  }
}
```
*   `403 Forbidden`: If the caller is not an `HR_ADMIN` or `SUPER_ADMIN`.
*   `409 Conflict`: If the email or phone number is already registered in the system.

---

## Module 2: Skills Taxonomy (Public/Read-Only)

Before an Employee can onboard, the frontend must display the available jobs and categories they can choose from. 

*(Note: The APIs to Add/Edit/Delete these skills will be defined later in the Admin API module. This is purely the public-facing fetch logic).*

### 2.1 Get All Categories & Skills
Returns a fully nested list of all active categories and their child skills.

**Endpoint:** `GET /api/v1/taxonomy`
**Rate Limit:** Standard (e.g., 60 per minute per IP).

**Responses:**
*   `200 OK`: Returns the nested taxonomy list.
```json
{
  "success": true,
  "data": [
    {
      "id": "nano_cat_rest",
      "name": "Restaurant / F&B",
      "skills": [
        { "id": "nano_waiter", "name": "Waiter / Server" },
        { "id": "nano_kitchen", "name": "Kitchen Helper" }
      ]
    },
    {
      "id": "nano_cat_retail",
      "name": "Retail / Store",
      "skills": [
        { "id": "nano_cashier", "name": "Cashier" },
        { "id": "nano_sales", "name": "Sales Associate" }
      ]
    }
  ],
  "meta": { "total_categories": 2 }
}
```

---

## Module 3: Super Admin Controls

This module defines the absolute top-level controls for the platform, strictly accessible only by the `SUPER_ADMIN`. 

### 3.1 Create Management Roles
Creates `ADMIN` and `HR_ADMIN` accounts. (General internal accounts like Verifiers are created by HR via the Module 1 invite API).

**Endpoint:** `POST /api/v1/admin/super/users`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "full_name": "Senior Manager",
  "email": "manager@shiftley.in",
  "phone_number": "+919876543200",
  "role": "HR_ADMIN"
}
```
**Responses:**
*   `201 Created`: User created and credentials emailed.

### 3.2 Revoke / Ban User
Instantly revokes access for an internal staff member or places a permanent ban on a public user (Employer/Employee).

**Endpoint:** `PATCH /api/v1/admin/users/{id}/status`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "status": "SUSPENDED",
  "reason": "Offboarding"
}
```
**Responses:**
*   `200 OK`: User status updated. *(Architecture Note: This action must immediately invalidate all active JWTs for this user in Redis).*

### 3.3 Create Taxonomy Category
Adds a new broad job category to the platform.

**Endpoint:** `POST /api/v1/admin/taxonomy/categories`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "name": "Warehouse / Logistics"
}
```
**Responses:**
*   `201 Created`: Returns the new Category NanoID.

### 3.4 Create Taxonomy Skill
Adds a specific job role under an existing category.

**Endpoint:** `POST /api/v1/admin/taxonomy/categories/{categoryId}/skills`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "name": "Forklift Operator"
}
```
**Responses:**
*   `201 Created`: Returns the new Skill NanoID.

### 3.5 Toggle Taxonomy State
Safely disables a skill or category so it no longer appears in public onboarding dropdowns, without deleting it (which would irrevocably break historical gig records).

**Endpoint:** `PATCH /api/v1/admin/taxonomy/skills/{id}`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "is_active": false
}
```
**Responses:**
*   `200 OK`: Skill visibility updated.

### 3.6 Update Platform Configuration
Updates global business variables like platform cuts or subscription fees without requiring an engineering code deployment.

**Endpoint:** `PATCH /api/v1/admin/config/fees`
**Headers:** `Authorization: Bearer <super_admin_jwt>`

**Request Body:**
```json
{
  "employer_subscription_monthly": 679.00,
  "employer_per_day_fee": 99.00,
  "worker_cancel_penalty": 50.00
}
```
**Responses:**
*   `200 OK`: Global configuration updated.

---

## Module 4: Verifier Operations

This module defines the critical endpoints used by field and desk Verifiers to authenticate users, ensuring the platform remains free of fraudulent employers and ghost workers.

### 4.1 Get Pending Queues
Fetches a paginated list of users awaiting verification.

**Endpoint:** `GET /api/v1/verifier/queue`
**Headers:** `Authorization: Bearer <verifier_jwt>`
**Query Params:**
*   `type`: `EMPLOYER` or `EMPLOYEE`
*   `cursor`: string (for pagination)

**Responses:**
*   `200 OK`: Returns the list. For `EMPLOYER`, this includes their business address and GPS coordinates for routing.

### 4.2 Verify Employer (Physical Visit)
Finalizes the physical location check. The verifier submits photographic proof. If the employer initially registered with an inaccurate GPS pin, the verifier actively corrects and overrides it here.

**Endpoint:** `POST /api/v1/verifier/employers/{id}/verify`
**Headers:** `Authorization: Bearer <verifier_jwt>`
**Content-Type:** `multipart/form-data`

**Form Data Fields:**
*   `status` (Text: `APPROVED` or `REJECTED`)
*   `notes` (Text: Reason for rejection or general notes)
*   `verified_location` (Text: JSON string `{"lat": 17.65, "lng": 83.21}` - used to override the employer's original location if needed)
*   `verifier_selfie` (File - Mandatory)
*   `location_photo_1` (File - Mandatory)
*   `location_photo_2` (File - Mandatory)
*   `location_photo_3` (File - Mandatory)

**Responses:**
*   `200 OK`: Employer is marked as `VERIFIED` and can post gigs. If `REJECTED`, the employer is locked and routed to the Customer Service appeal flow.
*   `400 Bad Request`: Missing mandatory photos for approval.

### 4.3 Verify Employee (Remote KYC)
Allows the verifier to remotely approve an employee after reviewing their submitted Aadhaar and profile picture against online KYC dashboards.

**Endpoint:** `POST /api/v1/verifier/employees/{id}/verify`
**Headers:** `Authorization: Bearer <verifier_jwt>`

**Request Body:**
```json
{
  "status": "APPROVED",
  "notes": "Aadhaar matched live facial call."
}
```
**Responses:**
*   `200 OK`: Employee status updated. If approved, they unlock the ability to apply for shifts. If rejected, they are routed to Customer Service appeal.

---

## Module 5: Employer Operations

This module acts as the core engine for verifying employers. It handles dashboard metrics, subscription plan purchases, gig creation, escrow payment handling via Razorpay, applicant handling, and QR-based shift attendance.

### 5.1 Employer Dashboard Profile
Fetches the employer's profile details along with critical business metrics (e.g., active subscription tier, remaining free posts).

**Endpoint:** `GET /api/v1/employers/me`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "profile": {
      "business_name": "Cafe Delight",
      "phone_number": "+919876543210",
      "address": "Vizag Beach Road",
      "gst_number": "22AAAAA0000A1Z5",
      "business_photo": "https://minio.../photo.jpg"
    },
    "stats": {
      "total_gigs_posted": 2,
      "free_gigs_remaining": 3,
      "active_plan": "NONE",
      "plan_expires_at": null
    }
  }
}
```
*   `403 Forbidden`: `{"error": "VERIFICATION_PENDING"}` - If the verifier hasn't manually approved them yet.

### 5.2 Purchase Subscription Plan
To post gigs beyond the 5 free initial posts, the employer must purchase a time-based subscription (Daily/Weekly/Monthly) which grants unlimited applicant hires for that duration.

**Endpoint:** `POST /api/v1/employers/me/subscription`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "plan_id": "monthly_unlimited"
}
```

**Responses:**
*   `200 OK`: Returns the Razorpay Order ID for the frontend to process the subscription charge.

### 5.3 Post a New Gig
Creates a gig. The backend evaluates the employer's free limit and subscription status. It also initiates a Razorpay Escrow order for the worker payout amount upfront.

**Endpoint:** `POST /api/v1/gigs`
**Headers:** `Authorization: Bearer <employer_jwt>`
**Idempotency-Key:** `nano_idem123`

**Request Body:**
```json
{
  "title": "Barista needed for weekend rush",
  "description": "Must have experience with espresso machines.",
  "category_id": "nano_cat_rest",
  "skill_id": "nano_barista",
  "start_time": "2026-05-01T09:00:00Z",
  "end_time": "2026-05-01T17:00:00Z",
  "pay_type": "PER_DAY",
  "wage_per_worker": 800,
  "workers_needed": 2
}
```

**Responses:**
*   `201 Created`: Gig created successfully and placed in draft/pending payment state.
```json
{
  "success": true,
  "data": {
    "gig_id": "gig_abc123",
    "razorpay_order_id": "order_XXXXX",
    "amount_to_escrow": 1600 
  }
}
```
*(Note: The gig remains invisible until the Razorpay payment webhook confirms the escrow is funded. `pay_type` is `PER_DAY` or `PER_HOUR`. All amounts stored in Paise internally).*

### 5.3a Wage Benchmark Check
Before posting, the employer app calls this to get the average market wage for a skill. If the employer's intended wage is below average, the app surfaces a non-blocking warning: "Most employers pay ₹X for this role. You may receive fewer applications."

**Endpoint:** `GET /api/v1/gigs/wage-benchmark?skill_id=nano_barista&pay_type=PER_DAY`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "skill": "Barista",
    "pay_type": "PER_DAY",
    "average_wage_paise": 75000,
    "minimum_wage_paise": 50000
  }
}
```

### 5.4 View Gig Applications
Fetches the list of employees who have applied for a specific gig.

**Endpoint:** `GET /api/v1/gigs/{gigId}/applications`
**Headers:** `Authorization: Bearer <employer_jwt>`
**Pagination:** Cursor-based

**Responses:**
*   `200 OK`: Returns detailed applicant cards.
```json
{
  "success": true,
  "data": [
    {
      "application_id": "app_123",
      "employee": {
        "id": "emp_xyz",
        "full_name": "Ravi Kumar",
        "profile_picture": "https://...",
        "work_experience_hrs": 120,
        "rating": 4.8,
        "degree": "B.Sc Culinary Arts",
        "specialization": "Espresso"
      },
      "status": "APPLIED"
    }
  ]
}
```

### 5.5 Approve Application
Hires a specific applicant for the gig slot.

**Endpoint:** `PATCH /api/v1/applications/{applicationId}/status`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{ "status": "APPROVED" }
```
**Responses:**
*   `200 OK`: Employee hired. (Once total `APPROVED` applications reaches `workers_needed`, the Gig status flips to `FILLED`).

### 5.6 Emergency "No-Show" Replacement API
If an approved worker pulls out or "no-shows" close to the shift start, the employer can instantly hire someone else from the existing application pool.

**Endpoint:** `POST /api/v1/gigs/{gigId}/emergency-hire`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "no_show_employee_id": "emp_111",
  "replacement_application_id": "app_222"
}
```
*(Backend Logic: Penalizes the no-show employee automatically and approves the new one).*

**Partial Refund Rule (Automated System Trigger):**
If the emergency replacement window closes (shift has started) and a no-show slot was **never filled** because no applicant from the pool accepted or was available, the system automatically triggers a **pro-rata partial refund** to the employer for exactly that unfilled slot.

**Example:** Employer escrows ₹5,000 for 10 workers at ₹500 each. 1 worker no-shows, no replacement found → system refunds exactly ₹500 back to the employer via Razorpay. The remaining 9 workers are paid normally from the escrow.

This is **not a manual API call** by the employer. The backend cron job running at shift-start detects unfilled confirmed slots and fires the Razorpay partial refund automatically. The event is logged and visible in the employer's gig history (`5.11`) as:
```json
{
  "unfilled_slots": 1,
  "partial_refund_paise": 50000,
  "refund_status": "PROCESSING_RAZORPAY"
}
```

### 5.7 Generate Shift QR Codes
Generates a time-sensitive, rotating QR code string for the Employer to display on their device. Arriving employees scan this to Clock-In / Clock-Out, verifying physical proximity.

**Endpoint:** `GET /api/v1/gigs/{gigId}/attendance-qr`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "qr_string": "shiftley://scan?gig=gig_abc123&action=CLOCK_IN&token=secretHash",
    "expires_in": 60 
  }
}
```
*(Note: Scanning the Clock-Out QR instantly triggers the Razorpay Route API to payout the worker from the Escrow).*

### 5.8 Rate Employee Post-Shift
Allows the employer to leave a star rating and comment for the employee once the shift ends.

**Endpoint:** `POST /api/v1/gigs/{gigId}/employees/{empId}/review`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Ravi handled the rush perfectly."
}
```

### 5.9 Raise Customer Support Ticket
If there is a dispute regarding payout, a no-show error, or platform issue.

**Endpoint:** `POST /api/v1/support/tickets`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "subject": "Worker left halfway through shift",
  "description": "Employee emp_xyz left at 2PM.",
  "related_gig_id": "gig_abc123"
}
```

### 5.10 Cancel Gig
Allows the employer to cancel a gig. The backend automatically calculates cancellation penalties based on the time remaining until the shift starts.

**Endpoint:** `POST /api/v1/gigs/{gigId}/cancel`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "reason": "Unexpected shop closure."
}
```
**Responses:**
*   `200 OK`: Gig cancelled successfully.
```json
{
  "success": true,
  "data": {
    "status": "CANCELLED",
    "refund_amount": 1200,
    "fine_deducted": 400,
    "message": "Cancelled < 2 hours before start. A 25% fine was applied and distributed to confirmed workers."
  }
}
```
*(Note: Platform subscription fees are strictly non-refundable. Funds are returned via Razorpay Refunds).*

### 5.11 View My Gigs (History & Active)
Allows the employer to see all past, active, and upcoming gigs they have created. Supports pagination.

**Endpoint:** `GET /api/v1/employers/me/gigs?status={status}&page=1&limit=20`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "gig_id": "gig_abc123",
      "title": "Kitchen Helper",
      "date": "2026-04-20",
      "status": "LIVE",
      "workers_needed": 3,
      "workers_accepted": 1,
      "escrow_amount_held_paise": 180000 
    }
  ],
  "meta": { "next_cursor": "..." }
}
```

### 5.12 Manual Check-In (QR Fallback)
If the worker's camera is broken or the QR fails to scan, the employer can manually mark the worker as arrived via the app.

**Endpoint:** `POST /api/v1/gigs/{gigId}/employees/{empId}/mark-arrived`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "status": "CHECKED_IN",
    "check_in_time": "2026-04-20T08:55:00Z"
  }
}
```

### 5.13 Manual Shift Complete (Trigger Payout)
The employer explicitly marks the gig as complete for a specific worker, immediately triggering the Razorpay Route payout rather than waiting for the 4-hour auto-release timer.

**Endpoint:** `POST /api/v1/gigs/{gigId}/employees/{empId}/complete`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Request Body:**
```json
{
  "hours_worked_override": null 
}
```
*(Overrides auto-calculated pro-rata if there's a mutual agreement on early leaving without penalty).*

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "status": "COMPLETED",
    "payout_status": "PROCESSING_RAZORPAY",
    "amount_released_paise": 60000
  }
}
```

### 5.14 View Full Worker Profile
Allows the employer to see the detailed resume, skills, degree, specialization, and past feedback of a worker before accepting their application.

**Endpoint:** `GET /api/v1/employers/profiles/employees/{empId}`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "employee_id": "emp_111",
    "name": "Ravi Kumar",
    "skills": ["Chef", "Kitchen Helper"],
    "education": {
      "degree": "B.Sc Hotel Management",
      "specialization": "Culinary Arts",
      "passing_year": 2021
    },
    "overall_rating": 4.8,
    "completed_shifts_count": 45,
    "recent_feedback": [
      { "rating": 5, "comment": "Excellent chef." }
    ]
  }
}
```

### 5.15 Close Gig with Full Refund (No Workers Selected)
If the employer posted a gig, funded the escrow, but did not approve any worker before the shift date, they can close the gig and receive a **100% full escrow refund**. No cancellation fine is applied since the employer was not at fault — the platform simply did not fill the slot.

**Endpoint:** `POST /api/v1/gigs/{gigId}/close-unfilled`
**Headers:** `Authorization: Bearer <employer_jwt>`

**Business Rules:**
*   Only valid if `workers_accepted == 0` (no one was ever approved).
*   If at least one worker was approved, this endpoint is blocked — the employer must use the standard `5.10 Cancel Gig` endpoint instead, which applies the tiered fine.

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "status": "CLOSED_UNFILLED",
    "refund_amount_paise": 180000,
    "fine_deducted_paise": 0,
    "message": "No workers were selected. Full escrow refunded via Razorpay."
  }
}
```
*   `400 Bad Request`: "Cannot close via this route. Workers were already approved. Use /cancel instead."
---

## Module 6: Notifications Engine (Global)
All system notifications are delivered asynchronously via WhatsApp Business API (Interakt) using pre-approved Meta templates. No Firebase Push, SMS, or WebSockets are used.
*   **OTP Delivery:** All authentication OTPs are sent strictly via WhatsApp.
*   **Gig Action:** Employer posts gig -> Nearby employees with matching `skill_id` receive WhatsApp broadcast.
*   **Application Event:** Employee applies -> Employer receives WhatsApp notification.
*   **Hiring Event:** Employer approves -> Employee receives WhatsApp message confirming the shift slot.
*   **Shift Reminders:** T-60 and T-45 minute attendance triggers are sent via WhatsApp with app deep links.
*   **Payment Event:** Employee scans Clock-Out QR -> Employee receives WhatsApp "Payment Disbursed" receipt.

---

## Module 7: Employee Operations
Core API endpoints powering the worker-facing Flutter app. Includes geospatial search, attendance confirmation, shift scanning, and penalty handling.

### 7.1 Employee Dashboard
Fetches the worker's rating, reliability status (no-show flags), and pending fines.

**Endpoint:** `GET /api/v1/employees/me`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "employee_id": "emp_111",
    "overall_rating": 4.8,
    "reliability_status": "GOOD",
    "no_show_count": 0,
    "active_fine_paise": 0
  }
}
```

### 7.2 Find Nearby Gigs (Geospatial Search)
Fetches gigs within a standard radius using PostGIS. Returns upcoming gigs sorted by distance. Gigs slightly outside the radius are included but flagged.

**Endpoint:** `GET /api/v1/gigs/search?lat=17.6868&lng=83.2184&radius_km=10`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "gig_id": "gig_abc123",
      "employer_name": "ABC Restaurant",
      "distance_km": 2.4,
      "wage_per_worker_paise": 60000,
      "date": "2026-04-20",
      "start_time": "09:00",
      "end_time": "17:00",
      "vacancies": 2,
      "total_needed": 3
    }
  ]
}
```

### 7.3 Apply for Gig
Allows the worker to apply. Backed by "First Accept Wins". Fails if the worker already has an accepted gig that overlaps with this time slot.

**Endpoint:** `POST /api/v1/gigs/{gigId}/apply`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `201 Created`: Application recorded.
*   `409 Conflict`: Conflict with an already accepted gig time slot.

### 7.4 Confirm Attendance (T-60 to T-45 mins)
Workers must hit this endpoint within 15 minutes of the 1-hour reminder to avoid a No-Show penalty. If they fail to confirm by T-45 mins, emergency replacement is triggered automatically.

**Endpoint:** `POST /api/v1/gigs/{gigId}/confirm-attendance`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`: Confirmed.
*   `400 Bad Request`: "Too early to confirm" or "Gig already triggered emergency replacement".

### 7.5 Scan Gig QR Code
Triggered when the worker scans the rotating QR code on the Employer's app. Logs the check-in or check-out time.

**Endpoint:** `POST /api/v1/gigs/{gigId}/scan-qr`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Request Body:**
```json
{
  "qr_token": "secretHashFromQR",
  "action": "CLOCK_IN" 
}
```
*(Action is either `CLOCK_IN` or `CLOCK_OUT` based on the QR contents)*.

**Responses:**
*   `200 OK`: 
```json
{
  "success": true,
  "data": {
    "status": "CHECKED_IN",
    "timestamp": "2026-04-20T08:52:00Z"
  }
}
```

### 7.6 Pay No-Show Fine (Unlock Account)
If a worker has `active_fine_paise: 5000` (₹50 fine) due to 2 no-shows, they cannot apply for new gigs until paid. This generates the Razorpay order to pay the fine.

**Endpoint:** `POST /api/v1/employees/me/pay-penalty`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "razorpay_order_id": "order_XYZ789",
    "amount_paise": 5000 
  }
}
```

### 7.7 Rate Employer Post-Shift
Worker reviews the employer out of 5 stars. This score contributes to the employer's internal ranking but is partially blinded to prevent retaliation.

**Endpoint:** `POST /api/v1/gigs/{gigId}/employer-review`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Manager was very polite."
}
```

### 7.8 Revoke Application
Allows the worker to withdraw an application. Fails if the worker tries to revoke an Accepted application within 1 hour of the shift start time.

**Endpoint:** `POST /api/v1/gigs/{gigId}/revoke-application`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`: Application revoked successfully.
*   `400 Bad Request`: "Too late to revoke. Shift starts in < 1 hour."

### 7.9 Submit Payout Profile (UPI/Bank)
Securely saves the worker's UPI ID or Bank details before their first payout. Stored using AES-256 encryption.

**Endpoint:** `PUT /api/v1/employees/me/payout-methods`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Request Body:**
```json
{
  "type": "UPI",
  "upi_id": "98XXXXXXXX@ybl"
}
```
**Responses:**
*   `200 OK`: Payout method updated.

### 7.10 View My Upcoming Schedule
Returns the worker's confirmed upcoming gigs. The app uses this to prevent double-applying to overlapping time slots ("First Accept Wins" lockout logic).

**Endpoint:** `GET /api/v1/employees/me/schedule`
**Headers:** `Authorization: Bearer <employee_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "gig_id": "gig_abc123",
      "employer_name": "ABC Restaurant",
      "date": "2026-04-20",
      "start_time": "09:00",
      "end_time": "17:00",
      "status": "CONFIRMED",
      "locked_slot": true
    }
  ]
}
```
*(The frontend uses `locked_slot: true` to grey out Apply buttons on any gig overlapping this time window).*

---

## Module 8: Data Analytics
Read-only queries to pull platform metrics, marketplace liquidity, and revenue sums. Designed for the Data Analytics role, hitting the PostGIS read-replicas.

### 8.1 Platform Overview
High-level growth metrics for the platform.

**Endpoint:** `GET /api/v1/analytics/overview?timeframe=this_month`
**Headers:** `Authorization: Bearer <analytics_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "total_verified_employers": 340,
    "total_active_workers": 1250,
    "gigs_posted": 850,
    "gigs_completed": 810
  }
}
```

### 8.2 Financial & Escrow Summaries
Tracks money movement and retained earnings without exposing PII.

**Endpoint:** `GET /api/v1/analytics/financials?timeframe=this_month`
**Headers:** `Authorization: Bearer <analytics_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "current_escrow_load_paise": 45000000,
    "subscription_revenue_paise": 15000000,
    "retained_cancellation_fines_paise": 850000,
    "total_worker_gmv_paise": 120000000
  }
}
```

### 8.3 Marketplace Liquidity
Critical operational metric tracking the balance of supply and demand.

**Endpoint:** `GET /api/v1/analytics/liquidity?skill_category=kitchen_staff`
**Headers:** `Authorization: Bearer <analytics_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "gig_fill_rate_percentage": 92.5,
    "worker_to_gig_ratio": 4.2,
    "most_demanded_skill": "Dishwasher"
  }
}
```

### 8.4 Operational Health
Measures the automated fallback engines and Verifier speeds.

**Endpoint:** `GET /api/v1/analytics/health`
**Headers:** `Authorization: Bearer <analytics_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "no_show_rate_percentage": 3.1,
    "emergency_trigger_rate_percentage": 4.5,
    "verifier_sla_breaches": 12 
  }
}
```

### 8.5 Customer Service Health
Aggregated breakdown of categorized CS manual interventions based on their WhatsApp account notes.

**Endpoint:** `GET /api/v1/analytics/customer-service?timeframe=this_month`
**Headers:** `Authorization: Bearer <analytics_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "total_cs_interventions": 142,
    "issues_by_category": {
      "PAYMENT_DISPUTE": 80,
      "VERIFICATION_DELAY": 42,
      "APP_BUG": 20
    }
  }
}
```

### 8.6 Log External Expenditures (Super Admin Only)
Allows the Super Admin to input off-platform costs (Marketing, AWS Infrastructure, Payroll) so the system can calculate true profit margins.

**Endpoint:** `POST /api/v1/analytics/expenditure`
**Headers:** `Authorization: Bearer <superadmin_jwt>`

**Request Body:**
```json
{
  "month": "2026-04",
  "category": "MARKETING",
  "amount_paise": 50000000,
  "description": "Facebook Ads for Employer Acquisition"
}
```
**Responses:**
*   `201 Created`

### 8.7 Profit & Loss (P&L) Statement (Super Admin Only)
Aggregates all platform revenues (subscriptions, fines) and subtracts logged expenditures to return the true Net Profit margin.

**Endpoint:** `GET /api/v1/analytics/pnl?month=2026-04`
**Headers:** `Authorization: Bearer <superadmin_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": {
    "month": "2026-04",
    "gross_revenue": {
      "subscriptions_paise": 15000000,
      "cancellation_fines_paise": 850000,
      "total_gross_paise": 15850000
    },
    "expenditures": {
      "marketing_paise": 5000000,
      "infrastructure_paise": 2000000,
      "payroll_paise": 4000000,
      "total_expenditure_paise": 11000000
    },
    "net_profit_paise": 4850000,
    "profit_margin_percentage": 30.5
  }
}
```

---

## Module 9: Customer Service (CS) Operations
Tightly scoped, search-only dashboard for CS agents to look up users and log note categories resulting from WhatsApp interactions. Note: CS agents cannot waive No-Show penalties.

### 9.1 Search User Profile & History
Look up an employer or worker by phone number or ID to see their booking and payment history.

**Endpoint:** `GET /api/v1/cs/users/search?phone=91XXXXXXXXXX`
**Headers:** `Authorization: Bearer <cs_agent_jwt>`

**Responses:**
*   `200 OK`: Returns aggregated view of user stats, ongoing gigs, escrow status, and strict no-show records.

### 9.2 Add Categorized Account Note
Logs an internal note against a user's profile to codify the WhatsApp support chat resolution.

**Endpoint:** `POST /api/v1/cs/users/{userId}/notes`
**Headers:** `Authorization: Bearer <cs_agent_jwt>`

**Request Body:**
```json
{
  "category": "PAYMENT_DISPUTE",
  "note": "Employer claimed worker left 2 hours early. Validated via manual QR mismatch."
}
```
**Responses:**
*   `200 OK`: Note attached to user timeline.

### 9.3 View Account Notes / Interaction Timeline
Retrieve the full log of all notes previously added by CS agents for a given user, to preserve context across agent shifts.

**Endpoint:** `GET /api/v1/cs/users/{userId}/notes`
**Headers:** `Authorization: Bearer <cs_agent_jwt>`

**Responses:**
*   `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "note_id": "note_001",
      "category": "PAYMENT_DISPUTE",
      "note": "Employer claimed worker left 2 hours early.",
      "created_by": "Priya (CS Agent)",
      "created_at": "2026-04-18T14:30:00Z"
    }
  ]
}
```

### 9.4 View Gig Details (CS Context)
CS agent can pull up the complete gig context: employer info, list of hired workers, escrow status, attendance logs, and QR scan timestamps.

**Endpoint:** `GET /api/v1/cs/gigs/{gigId}`
**Headers:** `Authorization: Bearer <cs_agent_jwt>`

**Responses:**
*   `200 OK`: Full gig object with attendance, escrow breakdown, and worker status.

### 9.5 Force Escrow Release (Payment Dispute Resolution)
When a payment dispute is validated (e.g., QR scan mismatch proved worker attended), the CS agent can manually trigger the escrow payout without waiting 4-hour auto-release. Strictly audited.

**Endpoint:** `POST /api/v1/cs/gigs/{gigId}/employees/{empId}/force-release`
**Headers:** `Authorization: Bearer <cs_agent_jwt>`

**Request Body:**
```json
{
  "reason": "QR scan mismatch confirmed. Worker was physically present per employer photo evidence.",
  "amount_paise": 60000
}
```
**Responses:**
*   `200 OK`: Payout triggered.
*   `403 Forbidden`: Insufficient CS permissions. Requires Super Admin co-approval for amounts > ₹5,000.

---

## Module 10: HR Admin Operations
Responsible for securely onboarding and managing the internal Shiftley workforce (Customer Service agents, Field Verifiers, and Data Analysts).

### 10.1 Create Internal Staff Account
Generates a restricted internal account with a specific role. Triggers a secure onboarding email to the staff member to set their initial password.

**Endpoint:** `POST /api/v1/hr/staff`
**Headers:** `Authorization: Bearer <hr_admin_jwt>`

**Request Body:**
```json
{
  "full_name": "Priya Sharma",
  "email": "priya.s@shiftley.in",
  "phone": "91XXXXXXXXXX",
  "internal_role": "CS_AGENT"
}
```
**Responses:**
*   `201 Created`: Staff account created and onboarding link sent.

### 10.2 Fetch Internal Staff Roster
View the directory of all active and inactive internal employees.

**Endpoint:** `GET /api/v1/hr/staff?role=VERIFIER&status=ACTIVE`
**Headers:** `Authorization: Bearer <hr_admin_jwt>`

**Responses:**
*   `200 OK`: Returns a paginated list of staff members and their system activity dates.

### 10.3 Suspend / Terminate Staff Account
Instantly revokes backend access for a departed internal employee.

**Endpoint:** `PATCH /api/v1/hr/staff/{staffId}/status`
**Headers:** `Authorization: Bearer <hr_admin_jwt>`

**Request Body:**
```json
{
  "status": "TERMINATED"
}
```
**Responses:**
*   `200 OK`: Access revoked. All active sessions invalidated immediately.

---

## Module 11: Webhooks (System Internal)
Asynchronous callbacks from Razorpay and Hyperverge. These endpoints are **not called by the Flutter app** — they are called by the payment and KYC gateways to notify Shiftley of events that completed out-of-band.

> All webhook endpoints validate the payload signature using HMAC-SHA256 before processing. Unverified requests are dropped with `400 Bad Request`.

### 11.1 Razorpay Payment Webhook
Receives async payment confirmation from Razorpay. On success, the backend marks the gig's escrow as `FUNDED` and flips the gig status from `PENDING_PAYMENT` to `LIVE`, making it visible to workers.

**Endpoint:** `POST /api/v1/webhooks/razorpay`
**Headers:** `X-Razorpay-Signature: <hmac_sha256_hash>`

**Request Body (sent by Razorpay):**
```json
{
  "event": "payment.captured",
  "payload": {
    "payment": {
      "entity": {
        "id": "pay_XXXXX",
        "order_id": "order_XXXXX",
        "amount": 180000,
        "status": "captured"
      }
    }
  }
}
```
**Responses:**
*   `200 OK`: Webhook acknowledged. Gig flipped to `LIVE`.
*   `400 Bad Request`: Invalid HMAC signature — request dropped.

### 11.2 Offline Aadhaar XML Verification
Strictly for Workers. Instead of third-party KYC, workers upload their UIDAI-signed Offline eKYC XML and share code. The backend verifies the digital signature and extracts verified demographics.

**Endpoint:** `POST /api/v1/auth/kyc/aadhaar-xml`
**Headers:** `Authorization: Bearer <registration_jwt>`

**Request Body (multipart/form-data):**
- `xml_file`: The .zip or .xml file from UIDAI.
- `share_code`: 4-digit code set by the user during download.

**Responses:**
*   `200 OK`: XML verified. Data extracted and saved.
```json
{
  "success": true,
  "data": {
    "name": "John Doe",
    "masked_aadhaar": "XXXX-XXXX-1234",
    "status": "VERIFIED"
  }
}
```
*   `400 Bad Request`: Invalid signature or incorrect share code.

### 11.3 WhatsApp Message Status Webhook
Receives delivery and read receipts from Meta's WhatsApp Business Cloud API. Used to track if notifications (like OTPs) are reaching the users.

**Endpoint:** `POST /api/v1/webhooks/whatsapp`
**Headers:** `X-Hub-Signature-256: <sha256_hash>`

**Responses:**
*   `200 OK`: Receipt acknowledged.

