# Shiftley: Spoon-Fed API Testing Playbook

This playbook provides the **exact values** and **exact payloads** you need to copy-paste into your terminal (or Postman) to test the platform.

---

## Scenario 1: Rahul's Cafe Onboarding & Hiring
**Goal**: Take Rahul from a new user to a Live Gig employer.

### Step 1: Rahul Requests an OTP
*   **Endpoint**: `POST /api/v1/auth/otp/send`
*   **Payload**:
```json
{
  "identifier": "rahul@bluetokai.com",
  "type": "EMAIL",
  "role": "EMPLOYER"
}
```
*   **Expected Response**: `200 OK`. (Check your terminal logs to see the code `123456`).

### Step 2: Rahul Verifies his Identity
*   **Endpoint**: `POST /api/v1/auth/otp/verify`
*   **Payload**:
```json
{
  "identifier": "rahul@bluetokai.com",
  "code": "123456"
}
```
*   **Expected Response**: 
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "registration"
  }
}
```
*   **Action**: Copy the `token`. This is your **Registration Token**.

### Step 3: Rahul Submits his Cafe Profile
*   **Endpoint**: `POST /api/v1/onboarding/employer`
*   **Header**: `Authorization: Bearer <registration_token>`
*   **Payload (Multipart Form)**:
    *   `business_name`: "Blue Tokai Cafe"
    *   `gst_number`: "29AAAAA0000A1Z5"
    *   `business_address`: "123, Koramangala 4th Block, Bangalore"
    *   `lat`: 12.9345
    *   `lng`: 77.6269
    *   `business_type_id`: (Use a UUID from taxonomy or "nano_cat_rest")
    *   `photos`: (Upload any small `.jpg` or `.png`)
*   **Expected Response**: Status `201 Created`. You get a **new token**. This is your **Session Token**.

### Step 4: Rahul Posts a Gig
*   **Endpoint**: `POST /api/v1/gigs`
*   **Header**: `Authorization: Bearer <session_token>`, `Idempotency-Key: rahul-gig-001`
*   **Payload**:
```json
{
  "title": "Weekend Barista",
  "description": "Serve espresso and handle the cash counter.",
  "category_id": "nano_cat_rest",
  "skill_id": "nano_barista",
  "wage_per_worker": 80000,
  "workers_needed": 1,
  "start_time": "2026-05-10T09:00:00Z",
  "end_time": "2026-05-10T17:00:00Z"
}
```
*   **Expected Response**: `201 Created`. The `amount_to_escrow` should be `80000` (₹800).

---

## Scenario 2: Sunil's Worker Journey
**Goal**: Sunil searches and applies for Rahul's gig.

### Step 1: Sunil Signs Up
*   Follow **Step 1 & 2** from Rahul's flow, but use `sunil@gmail.com` and `role: "WORKER"`.

### Step 2: Sunil Onboards
*   **Endpoint**: `POST /api/v1/onboarding/employee`
*   **Header**: `Authorization: Bearer <registration_token>`
*   **Payload (Multipart Form)**:
    *   `full_name`: "Sunil Kumar"
    *   `aadhaar_number`: "123456789012"
    *   `skills`: ["nano_barista", "nano_waiter"]
    *   `lat`: 12.9300
    *   `lng`: 77.6200
*   **Expected Response**: `201 Created`. You get Sunil's **Session Token**.

### Step 3: Sunil Searches for Work
*   **Endpoint**: `GET /api/v1/gigs/search?lat=12.9300&lng=77.6200&radius=10`
*   **Header**: `Authorization: Bearer <sunil_session_token>`
*   **Expected Response**: Sunil should see "Blue Tokai Cafe - Weekend Barista" in the list.

### Step 4: Sunil Applies
*   **Endpoint**: `POST /api/v1/gigs/{gig_id}/apply`
*   **Payload**: `{"notes": "I have 2 years of experience at Starbucks."}`
*   **Expected Response**: `201 Created`.

---

## Scenario 3: Admin Management & Security
**Goal**: Verify privacy and role restrictions.

### Test 1: Check Aadhaar Masking
*   **Endpoint**: `GET /api/v1/employees/profile`
*   **Header**: `Authorization: Bearer <sunil_session_token>`
*   **Expected Response**: Look for `"aadhaar_number": "XXXXXXXX9012"`. It **must** be masked.

### Test 2: Verify Token Isolation
*   **Endpoint**: `POST /api/v1/gigs` (Attempt to post a gig)
*   **Header**: `Authorization: Bearer <sunil_session_token>` (Worker Token)
*   **Expected Response**: `403 Forbidden`. A Worker cannot post a Gig.
