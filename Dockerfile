FROM golang:1.21 AS builder 
WORKDIR /app
COPY main.go .
RUN go build -o myapp main.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/myapp /app/myapp
RUN adduser -D appuser
USER appuser
ENTRYPOINT ["./myapp"]
