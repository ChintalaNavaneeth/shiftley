# Shiftley Infrastructure & Local Development

This directory contains everything needed to spin up the local development environment for **Shiftley.in**. We use a containerized stack to ensure consistency across development, staging, and production.

## 🚀 Quick Start

To spin up the entire infrastructure including the Go backend and all backing services:

```powershell
# Navigate to the docker directory
cd infrastructure/docker

# Build and start the containers
docker compose up -d --build
```

To stop the environment and wipe all data (useful for schema resets):
```powershell
docker compose down -v
```

---

## 🔗 Service Dashboard

| Service | Local URL / Endpoint | Port | Description |
|---|---|---|---|
| **Backend API** | [http://localhost:8080](http://localhost:8080) | `8080` | The Go Gin server. |
| **Swagger UI** | [http://localhost:8080/swagger/index.html](http://localhost:8080/swagger/index.html) | `8080` | Interactive API documentation. |
| **MinIO Console**| [http://localhost:9001](http://localhost:9001) | `9001` | Dashboard for managing file storage (Buckets). |
| **pgAdmin 4** | [http://localhost:5050](http://localhost:5050) | `5050` | Web UI for exploring the PostgreSQL database. |
| **PostgreSQL** | `localhost:5432` | `5432` | Primary DB with PostGIS support. |
| **Redis** | `localhost:6379` | `6379` | In-memory store for OTPs & rate limiting. |

### Default Credentials
*   **Postgres**: `postgres` / `root` (DB Name: `postgres`)
*   **pgAdmin**: `admin@shiftley.in` / `admin`
*   **MinIO**: `admin` / `admin123`

---

## 🐳 Docker Stack

We use professional-grade images to power the platform:

1.  **PostgreSQL (`postgis/postgis:15-3.4`)**: Optimized for geospatial proximity matching between workers and gigs.
2.  **Redis (`redis:alpine3.23`)**: Lightweight and fast, used for high-frequency OTP storage.
3.  **Go Backend (`shiftley-backend:dev`)**: A custom multi-stage build:
    *   **Builder**: `registry.suse.com/bci/golang:1.21`
    *   **Runtime**: `registry.suse.com/bci/bci-base:15.5` (Statically linked binary).

---

## 💾 Database Schema

The database is automatically initialized on the first boot using the master schema file:
📍 `infrastructure/postgres/shiftley_schema.sql`

This file creates the `shiftley` schema and all **37 core tables**, including:
*   User & Worker Profiles
*   Skill Taxonomy (Business Types, Skills, etc.)
*   Gig Lifecycle (Requests, Assignments, Fines)
*   Financials (Transactions, Expenditures)
*   Notifications & Audit Logs

---

## 🛠️ Storage (MinIO)

The system automatically creates these buckets on startup:
*   `profile-pictures`: Publicly accessible images.
*   `kyc-documents`: Private encrypted storage for identity verification.
*   `business-documents`: Private storage for employer business proofs.
