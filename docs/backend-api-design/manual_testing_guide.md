# Shiftley: Master Manual Testing & Onboarding Guide

Follow this guide step-by-step to test the entire Shiftley ecosystem.

---

## Phase 1: Super Admin Initial Setup
*Goal: Claim the root account and set your real phone number.*

1. **Step 1: Request Root OTP**
   - **Endpoint**: `POST /api/v1/auth/otp/send`
   - **Action**: Request code for the root account.
   - **Form Data**: `identifier: +910000000000`, `type: PHONE`, `role: SUPER_ADMIN`
   - **What to look for**: `200 OK` and `OTP sent successfully` message.

2. **Step 2: Verify Root OTP**
   - **Endpoint**: `POST /api/v1/auth/otp/verify`
   - **Form Data**: `identifier: +910000000000`, `type: PHONE`, `code: [FROM_LOGS]`
   - **What to look for**: `registration_token` in the response data. Copy this.

3. **Step 3: Setup Account (Claiming)**
   - **Action**: Click **Authorize** (green lock) and paste the `registration_token`.
   - **Endpoint**: `PATCH /api/v1/admin/super/setup`
   - **JSON Body**:
     ```json
     {
       "full_name": "Your Real Name",
       "email": "admin@shiftley.in",
       "phone_number": "+919999999999"
     }
     ```
   - **What to look for**: `Super Admin setup complete` message.

4. **Step 4: Login to your New Identity**
   - **Action**: Repeat Step 1 & 2 using your **new number** (`+919999999999`).
   - **What to look for**: A `session_token` and `is_new_user: false`.
   - **Action**: **Authorize** Swagger with this session token for all future admin tasks.

---

## Phase 2: Internal Staff Onboarding
*Goal: Create the people who run the platform.*

1. **Step 1: Invite a Verifier**
   - **Endpoint**: `POST /api/v1/admin/users/invite`
   - **JSON Body**:
     ```json
     {
       "full_name": "Joe Verifier",
       "email": "joe@shiftley.in",
       "phone_number": "+911111100000",
       "aadhaar_number": "123412341234",
       "role": "VERIFIER"
     }
     ```
   - **What to look for**: `User VERIFIER created` message.

2. **Step 2: Verifier Login**
   - **Action**: Log in as the Verifier using `+911111100000` (OTP Flow) to get their **Verifier Session Token**.
   - **What to look for**: `session_token` with `role: VERIFIER`.

---

## Phase 3: Public User Registration
*Goal: Create an Employer and an Employee.*

1. **Step 1: Employer Registration**
   - **Action**: Call `otp/send` and `otp/verify` for `+918888800000` with `role: EMPLOYER`.
   - **Action**: Authorize with the Employer's `registration_token`.
   - **Endpoint**: `POST /api/v1/onboarding/employer` (Multipart/Form-Data)
   - **What to look for**: `Employer profile created` message.

2. **Step 2: Employee Registration**
   - **Action**: Call `otp/send` and `otp/verify` for `+917777700000` with `role: WORKER`.
   - **Action**: Authorize with the Employee's `registration_token`.
   - **Endpoint**: `POST /api/v1/onboarding/employee` (Multipart/Form-Data)
   - **What to look for**: `Worker profile created` message.

---

## Phase 4: Verification Flow
*Goal: Verifier approves the users.*

1. **Step 1: Get Pending IDs**
   - **Action**: Authorize as **Verifier**.
   - **Endpoint**: `GET /api/v1/verifier/queue`
   - **What to look for**: Copy the `id` of the employer and employee.

2. **Step 2: Approve Employer**
   - **Endpoint**: `POST /api/v1/verifier/employers/{id}/verify`
   - **JSON Body**:
     ```json
     {
       "status": "APPROVED",
       "notes": "Legit business, site visited.",
       "location_photo_1_url": "http://img.com/shop.jpg"
     }
     ```

3. **Step 3: Approve Employee**
   - **Endpoint**: `POST /api/v1/verifier/employees/{id}/verify`
   - **JSON Body**:
     ```json
     {
       "status": "APPROVED",
       "notes": "KYC Cleared"
     }
     ```

---

## Phase 5: Post-Verification & Subscriptions
*Goal: Prepare the Employer to post gigs.*

2. **Step 2: Purchase & Check Limits**
   - **Endpoint**: `POST /api/v1/employers/me/subscription`
   - **Body**: `{ "plan_id": "daily_access" }` (or `weekly_unlimited`, `monthly_unlimited`)
   - **What to look for**: `201 Created` with `status: ACTIVE` and your `expires_at`.
   - **Check Limits**: Call `GET /api/v1/employers/me`.
   - **Note**: You will see `free_gigs_remaining` based on your plan (5 for Daily, 40 for Weekly, 200 for Monthly).

---

## Phase 6: Full Gig Lifecycle
*Goal: From posting to payment.*

1. **Step 1: Post Gig (Employer)**
   - **Endpoint**: `POST /api/v1/gigs`
   - **JSON Body**:
     ```json
     {
       "title": "Delivery Executive",
       "skill_id": "[PASTE_FROM_TAXONOMY]",
       "slot_count": 1,
       "pay_paise": 150000,
       "pay_structure": "PER_DAY",
       "workers_needed": 2,
       "latitude": 12.97, "longitude": 77.59,
       "start_date": "2026-06-01", "end_date": "2026-06-01",
       "start_time": "09:00:00", "end_time": "18:00:00"
     }
     ```
   - **What to look for**: `201 Created` with a `gig_id`.
   - **Limit**: `workers_needed` max is **10**. Sending more returns `400 Bad Request`.

2. **Step 2: Search & Apply (Employee)**
   - **Action**: Authorize as **Employee**.
   - **Endpoint**: `GET /api/v1/gigs/search`
   - **Action**: Call `POST /api/v1/gigs/{gigId}/apply` using the ID from search.

3. **Step 3: Approve Application (Employer)**
   - **Action**: Authorize as **Employer**.
   - **Endpoint**: `PATCH /api/v1/applications/{id}/status`
   - **JSON Body**: `{ "status": "ACCEPTED" }`

4. **Step 4: Check-in (Attendance)**
   - **Endpoint**: `POST /api/v1/gigs/{id}/scan-qr`
   - **JSON Body**:
     ```json
     {
       "worker_id": "[WORKER_ID]",
       "type": "CHECK_IN"
     }
     ```

5. **Step 5: Completion & Review**
   - **Endpoint**: `POST /api/v1/gigs/{id}/employer-review`
   - **JSON Body**: `{ "score": 5, "comment": "Great work!" }`

---

## Phase 7: Advanced Visibility & Management
*Goal: Oversight and Financials.*

1. **Step 1: View System Ledger (Admin/Analyst)**
   - **Endpoint**: `GET /api/v1/analytics/ledger`
   - **What to look for**: List of all money movements (escrow, payouts).

2. **Step 2: Support Tickets**
   - **Endpoint**: `POST /api/v1/support/tickets`
   - **JSON Body**:
     ```json
     {
       "subject": "Payment issue",
       "description": "My payout is delayed."
     }
     ```
