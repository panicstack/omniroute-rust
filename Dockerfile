
# Build stage
FROM rust:1-bookworm AS builder

WORKDIR /build

# Copy source code and lockfile
COPY . .

# Compile the application in release mode
RUN cargo build --release --locked

# Runtime stage
FROM debian:bookworm-slim

ENV PORT=20128 \
    OMNIROUTE_DATA_DIR=/data \
    DATA_DIR=/data \
    RUST_LOG=info

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --system --create-home --home-dir /app omniroute && \
    mkdir -p /data && \
    chown -R omniroute:omniroute /data

COPY --from=builder \
    /build/target/release/omniroute \
    /usr/local/bin/omniroute

USER omniroute

EXPOSE 20128

CMD ["omniroute", "serve", "--host", "0.0.0.0", "--port", "20128"]
