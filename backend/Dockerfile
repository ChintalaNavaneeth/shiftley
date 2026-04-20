# Build Stage
FROM registry.suse.com/bci/golang:1.26 as builder

WORKDIR /app

# Copy all source code first
COPY . .

# Initialize module if go.mod is missing, then tidy and build
RUN if [ ! -f go.mod ]; then go mod init shiftley; fi && \
    go install github.com/swaggo/swag/cmd/swag@v1.16.2 && \
    swag init --parseDependency && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -o main .

# Run Stage
FROM registry.suse.com/bci/golang:1.26

WORKDIR /app

# Copy the binary from the build stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Command to run the application
CMD ["./main"]
