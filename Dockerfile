# Stage 1: Build frontend
FROM node:22-alpine AS frontend
WORKDIR /app/web/frontend
COPY web/frontend/package*.json ./
RUN npm install --legacy-peer-deps
COPY web/frontend/ ./
RUN npm run build

# Stage 2: Build Go binary
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=frontend /app/web/dist/ ./web/dist/
RUN CGO_ENABLED=0 GOOS=linux go build -o video-subscribe-dl ./cmd/server

# Stage 3: Final image
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata ffmpeg
WORKDIR /app
COPY --from=builder /app/video-subscribe-dl .
EXPOSE 8080
ENTRYPOINT ["./video-subscribe-dl"]
