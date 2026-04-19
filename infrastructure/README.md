# Shiftley Infrastructure Guide

This document covers the local development infrastructure setup for the Shiftley platform.

## 🐳 Docker Stack

We use a containerized stack to provide all necessary backing services. The Go backend also runs within this stack for consistent environment handling.

### Docker Images Used

| Image ID/Name | Role | Description |
|---|---|---|
| `registry.suse.com/suse/postgres:18-contrib` | **Primary Database** | PostgreSQL 18 with PostGIS extensions for proximity matching. |
| `redis:alpine3.23` | **Cache & Rate Limiting** | Fast in-memory store for OTPs and API rate limit counters. |
| `minio/minio` | **Object Storage** | S3-compatible storage for profile pictures and KYC documents. |
| `dpage/pgadmin4:latest` | **Database Management** | Web-based UI for managing PostgreSQL. |
| `shiftley-backend:dev` | **Go API Server** | Built from `registry.suse.com/bci/golang:1.26` (builder) and `registry.suse.com/bci/bci-base:15.7` (runner). |

---

## 🔗 Service URLs & Credentials

| Service | Local URL | Credentials |
|---|---|---|
| **Backend API** | [http://localhost:8080](http://localhost:8080) | - |
| **Swagger UI** | [http://localhost:8080/swagger/index.html](http://localhost:8080/swagger/index.html) | API Bearer Auth |
| **Health Check** | [http://localhost:8080/health](http://localhost:8080/health) | - |
| **MinIO Console**| [http://localhost:9001](http://localhost:9001) | `admin` / `admin123` |
| **MinIO API** | [http://localhost:9000](http://localhost:9000) | `admin` / `admin123` |
| **pgAdmin** | [http://localhost:5050](http://localhost:5050) | `admin@shiftley.in` / `admin` |
| **PostgreSQL** | `localhost:5432` | `postgres` / `root` |
| **Redis** | `localhost:6379` | (No password) |

---

## 🚀 How to Start

The fastest way to start the environment is using the helper script:

```powershell
# From the project root
.\infrastructure\scripts\dev-up.ps1
```

Alternatively, use the standard Docker Compose command:
```powershell
cd infrastructure/docker
docker-compose up -d --build
```

---

## 📂 Infrastructure Structure

- `infrastructure/docker/`: Contains the `docker-compose.yml` and service definitions.
- `infrastructure/postgres/`: pgAdmin server configurations.
- `infrastructure/redis/`: Redis performance and memory configurations.
- `infrastructure/scripts/`: Utility scripts for development lifecycle.
- `backend/internal/data/migrations/`: Unified source of truth for the DB schema.

---

## 🛠️ Storage Buckets (MinIO)

The following buckets are automatically created on startup:
1. `profile-pictures`: **Public** read access.
2. `kyc-documents`: **Private** (Signed URLs only).
3. `business-documents`: **Private** (Signed URLs only).
