# Build Stage
FROM registry.suse.com/bci/golang:1.26 as builder

WORKDIR /app

# Pre-install swag to cache the tool layer
RUN go install github.com/swaggo/swag/cmd/swag@v1.16.2

# Copy dependency files first
COPY go.mod go.sum ./
# Copy vendor directory (this is where the "bin" of packages lives)
COPY vendor/ ./vendor/

# Copy the rest of the source code
COPY . .

# Generate swagger docs and build using the vendor folder
RUN swag init --parseDependency && \
    CGO_ENABLED=0 GOOS=linux go build -mod=vendor -o main .

# Run Stage
FROM registry.suse.com/bci/golang:1.26

WORKDIR /app

# Copy the binary from the build stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Command to run the application
CMD ["./main"]
