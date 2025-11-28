# Multi-stage build for Go Auth API
# Stage 1: Build the application
FROM golang:1.18-alpine as builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o auth-api .

# Stage 2: Create minimal runtime image
FROM alpine:3.18

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/auth-api .

# Expose port 8000
EXPOSE 8000

# Run the application
CMD ["./auth-api"]

