# Shiftley API Documentation

This document outlines the implemented APIs for the Shiftley platform, including authentication, onboarding, and core management features.

---

## 1. Authentication (`/auth`)

### 1.1 Send OTP
Initiates the login or registration process by sending a 6-digit OTP.

- **Endpoint**: `POST /api/v1/auth/otp/send`
- **Content-Type**: `application/x-www-form-urlencoded` or `application/json`
- **Request Body**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `identifier` | `string` | Yes | Phone number (e.g., `+91XXXXXXXXXX`) or Email |
  | `type` | `string` | Yes | `PHONE` or `EMAIL` |
  | `role` | `string` | Yes | `WORKER`, `EMPLOYER`, `VERIFIER`, `CS_AGENT`, `ANALYST`, `ADMIN`, `SUPER_ADMIN` |

- **Response Codes**:
  - `200 OK`: OTP sent successfully.
  - `400 Bad Request`: Validation error (invalid role or identifier).
  - `500 Internal Server Error`: Failed to send OTP.

- **Sample Response**:
  ```json
  {
    "status": "success",
    "message": "OTP sent successfully to your registered contact methods",
    "data": null
  }
  ```

### 1.2 Verify OTP
Verifies the OTP and issues security tokens.

- **Endpoint**: `POST /api/v1/auth/otp/verify`
- **Content-Type**: `application/x-www-form-urlencoded` or `application/json`
- **Request Body**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `identifier` | `string` | Yes | Phone number or Email used in Send OTP |
  | `type` | `string` | Yes | `PHONE` or `EMAIL` |
  | `code` | `string` | Yes | 6-digit OTP received |

- **Expected Behavior**:
  - If **New User**: Returns a `registration_token` (used for onboarding).
  - If **Existing User**: Returns an `access_token` and `refresh_token`.

- **Response Codes**:
  - `200 OK`: Verification successful.
  - `400 Bad Request`: Incorrect or expired OTP.

- **Sample Response (Existing User)**:
  ```json
  {
    "status": "success",
    "data": {
      "is_new_user": false,
      "access_token": "eyJhbG...",
      "refresh_token": "eyJhbG...",
      "is_initial_setup_complete": true,
      "user": {
        "id": "uuid",
        "role": "WORKER"
      }
    }
  }
  ```

### 1.3 Refresh Token
Rotates the session by issuing a new access/refresh token pair.

- **Endpoint**: `POST /api/v1/auth/token/refresh`
- **Request Body**:
  ```json
  {
    "refresh_token": "string"
  }
  ```

- **Response Codes**:
  - `200 OK`: Tokens rotated successfully.
  - `401 Unauthorized`: Invalid or expired refresh token.

### 1.4 Logout
Invalidates the current session and revokes the refresh token.

- **Endpoint**: `POST /api/v1/auth/logout`
- **Security**: `Bearer AccessToken`
- **Response Codes**:
  - `200 OK`: Logged out successfully.

---

## 2. Onboarding (`/onboarding`)

> [!IMPORTANT]
> All onboarding endpoints require a `registration` type JWT token in the Authorization header.

### 2.1 Onboard Employer
- **Endpoint**: `POST /api/v1/onboarding/employer`
- **Content-Type**: `multipart/form-data`
- **Request Body**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `full_name` | `string` | Yes | Owner's full name |
  | `business_name` | `string` | Yes | Name of the entity |
  | `location` | `string` | Yes | JSON: `{"lat": 12.97, "lng": 77.59}` |
  | `aadhaar_pdf` | `file` | Yes | PDF scan of Aadhaar |
  | `business_photo_1` | `file` | Yes | Shop/Office photo |

### 2.2 Onboard Employee (Worker)
- **Endpoint**: `POST /api/v1/onboarding/employee`
- **Content-Type**: `multipart/form-data`
- **Request Body**:
  | Field | Type | Required | Description |
  | :--- | :--- | :--- | :--- |
  | `full_name` | `string` | Yes | Worker's full name |
  | `skill_ids` | `string` | Yes | JSON Array of Skill UUIDs: `["id1", "id2"]` |
  | `profile_picture` | `file` | Yes | High-quality selfie/portrait |

---

## 3. KYC (`/auth/kyc`)

### 3.1 Aadhaar XML Verification
- **Endpoint**: `POST /api/v1/auth/kyc/aadhaar-xml`
- **Security**: `Bearer RegistrationToken`
- **Content-Type**: `multipart/form-data`
- **Fields**: `xml_file` (file), `share_code` (string)

---

## 4. Taxonomy (`/taxonomy`)

### 4.1 Get All Categories & Skills
Returns the entire tree of available skills for registration.

- **Endpoint**: `GET /api/v1/taxonomy`
- **Sample Response**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "uuid",
        "name": "Hospitality",
        "skills": [
          { "id": "uuid", "name": "Waiter" },
          { "id": "uuid", "name": "Chef" }
        ]
      }
    ]
  }
  ```

---

## 5. Error Handling & Response Codes

All API responses follow a standard wrapper:
```json
{
  "status": "success | error",
  "message": "Human readable message",
  "data": { ... },
  "errors": [ "list of specific errors" ]
}
```

| Code | Meaning |
| :--- | :--- |
| `200` | Success |
| `201` | Created (Resource successfully added) |
| `400` | Bad Request (Validation or logic error) |
| `401` | Unauthorized (Missing or invalid token) |
| `403` | Forbidden (Token valid, but insufficient role) |
| `404` | Not Found |
| `500` | Internal Server Error |
