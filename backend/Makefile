# Makefile for Shiftley Go Backend

.PHONY: run dev build test lint swagger

run:
	go run cmd/api/main.go

dev:
	# Requires air for hot-reloading (go install github.com/cosmtrek/air@latest)
	air

build:
	go build -o bin/server cmd/api/main.go

test:
	go test -v ./...

lint:
	# Requires golangci-lint
	golangci-lint run

swagger:
	# Requires swag (go install github.com/swaggo/swag/cmd/swag@latest)
	swag init -g cmd/api/main.go
