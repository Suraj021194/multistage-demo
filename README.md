# Multi-Stage Build Demo

A tiny Go program used to show how much a multi-stage Docker build can shrink an image.

## The idea
Go compiles to a standalone binary. The compiler is only needed to build it, not to run it. A multi-stage build compiles in one stage and ships only the binary in a second, minimal stage.

## Dockerfile
```dockerfile
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
```

## Result
| Version | Image size |
|---|---|
| Single-stage (build and run in `golang:1.21`) | 1.23GB |
| Multi-stage (binary copied into `alpine`) | 15.9MB |

Both images produce identical output. The size was read from the `DISK USAGE` column of `docker images`.

## Run it
```bash
docker build -t multistage-demo .
docker run multistage-demo
docker images multistage-demo
```

## What this shows
- Deleting files in a later layer does not shrink an image, because earlier layers are immutable. Multi-stage builds avoid the problem by never including the build tools in the final image.
- Alpine has no `useradd`. It uses `adduser -D` (the `-D` flag skips the password prompt, which a non-interactive build can't answer).
- Base images are not interchangeable. Different distros ship different tools.
