# Shiftley: Master API Testing Reference

This document provides a comprehensive list of every API endpoint in the system, organized by module, for manual and automated testing.

---

## 1. Authentication Module (`/auth`)
**Goal**: Handle identity verification and token generation.

| Endpoint | Method | Payload | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/otp/send` | `POST` | `{"identifier": "...", "type": "EMAIL", "role": "WORKER"}` | `200 OK` + Mock Log entry |
| `/otp/verify` | `POST` | `{"identifier": "...", "code": "123456"}` | `200 OK` + `registration` token |

---

## 2. Onboarding Module (`/onboarding`)
**Goal**: Convert new users into verified profiles. Requires `registration` token.

| Endpoint | Method | Payload (Multipart) | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/employer` | `POST` | `business_name`, `gst`, `address`, `lat`, `lng`, `photos` | `201 Created` + `session` token |
| `/employee` | `POST` | `full_name`, `aadhaar_number`, `skills[]`, `lat`, `lng`, `photo` | `201 Created` + `session` token |

---

## 3. Gig Module (`/gigs`)
**Goal**: The core marketplace engine. Requires `session` token.

| Endpoint | Method | Payload / Query | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/` (Post Gig) | `POST` | `{"title": "...", "wage_per_worker": 100000, ...}` | `201 Created` + Razorpay ID |
| `/search` | `GET` | `?lat=...&lng=...&radius=10&skill_id=...` | `200 OK` + List of Gigs |
| `/:id` | `GET` | (None) | `200 OK` + Gig Details |
| `/:id/apply` | `POST` | `{"notes": "I am experienced"}` | `201 Created` |
| `/:id/confirm-attendance` | `POST` | (None) | `200 OK` + Employee status update |
| `/:id/scan-qr` | `POST` | `{"qr_string": "..."}` | `200 OK` + Clock-in timestamp |
| `/:id/cancel` | `POST` | `{"reason": "Family emergency"}` | `200 OK` + Status update |
| `/:id/rate` | `POST` | `{"to_user_id": "...", "rating": 5, "comment": "..."}` | `201 Created` |

---

## 4. Verifier Module (`/verifier`)
**Goal**: Physical/Manual verification of business sites.

| Endpoint | Method | Payload | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/employers` | `GET` | `?status=PENDING` | `200 OK` + List for approval |
| `/employers/:id/verify` | `POST` | `{"status": "APPROVED", "lat_override": 12.9, ...}` | `200 OK` + Profile Sync |

---

## 5. Admin & Management Module (`/admin`)
**Goal**: Internal staff management and platform config.

| Endpoint | Method | Payload | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/users/invite` | `POST` | `{"full_name": "...", "email": "...", "role": "VERIFIER"}` | `201 Created` + Email Mock |
| `/super/users` | `POST` | `{"full_name": "...", "email": "...", "role": "ADMIN"}` | `201 Created` (SuperAdmin only) |
| `/config/fees` | `PATCH` | `{"employer_subscription_monthly": 1499.00}` | `200 OK` + Global update |
| `/users/:id/status` | `PATCH` | `{"status": "SUSPENDED", "reason": "Fraud"}` | `200 OK` + Token Blacklist |
| `/taxonomy/business-types`| `POST` | `{"name": "...", "description": "..."}` | `201 Created` |
| `/taxonomy/skill-categories`| `POST` | `{"business_type_id": "...", "name": "..."}` | `201 Created` |
| `/taxonomy/skills` | `POST` | `{"category_id": "...", "name": "..."}` | `201 Created` |

---

## 6. Support & Analytics (`/support` & `/analytics`)
**Goal**: Customer service and business intelligence.

| Endpoint | Method | Payload | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/tickets` | `POST` | `{"subject": "...", "description": "...", "gig_id": "..."}` | `201 Created` |
| `/dashboard/stats` | `GET` | (None) | `200 OK` + GMV, Active Users, Gigs |

---

## 7. Employee & Employer Profiles (`/employees` & `/employers`)
**Goal**: Individual profile management.

| Endpoint | Method | Payload | Success Criteria |
| :--- | :--- | :--- | :--- |
| `/employees/profile` | `GET` | (None) | `200 OK` + Profile Details (Masked Aadhaar) |
| `/employers/profile` | `GET` | (None) | `200 OK` + Profile Details |
| `/employers/gigs` | `GET` | (None) | `200 OK` + Employer's Gig History |

---

## Mandatory Security Check-List for Testing:
1.  **Aadhaar Privacy**: Call `GET /employees/profile`. Verify that the `aadhaar_number` field only shows 4 digits (e.g., `XXXXXXXX1234`).
2.  **Token Segregation**: Try calling `POST /gigs` with a `registration` token. It **must** return `403 Forbidden`.
3.  **Role Enforcement**: Try calling `POST /admin/config/fees` with a `WORKER` session token. It **must** return `403 Forbidden`.
