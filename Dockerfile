
# Build stage
FROM rust:1-bookworm AS builder

WORKDIR /build
COPY . .
RUN cargo build --release --locked

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --system --create-home --home-dir /app omniroute && \
    mkdir -p /app/data && \
    chown -R omniroute:omniroute /app

COPY --from=builder \
    /build/target/release/omniroute \
    /usr/local/bin/omniroute

ENV PORT=20128 \
    OMNIROUTE_DATA_DIR=/app/data \
    DATA_DIR=/app/data

USER omniroute
WORKDIR /app

EXPOSE 20128

CMD ["omniroute", "serve", "--host", "0.0.0.0", "--port", "20128"]
