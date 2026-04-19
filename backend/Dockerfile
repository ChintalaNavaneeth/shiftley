# Stage 1: Build
FROM registry.suse.com/bci/golang:1.21 AS builder

WORKDIR /app

# Copy go.mod and go.sum (if exists)
COPY go.mod go.sum* ./

# Download dependencies (skip if go.sum doesn't exist yet, but we'll try)
# RUN go mod download

# Copy the source code
COPY . .

# Build the project
RUN go mod tidy
RUN CGO_ENABLED=0 go build -o /app/bin/server cmd/api/main.go

# Stage 2: Runtime
FROM registry.suse.com/bci/bci-base:15.5

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/bin/server /app/server

# Copy .env.docker for default environment (or it can be passed via Compose)
# COPY .env.docker /app/.env

# Expose the API port
EXPOSE 8080

# Run the server
CMD ["/app/server"]
