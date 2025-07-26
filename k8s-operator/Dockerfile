FROM rust:1.81 as builder

WORKDIR /app

# Copy manifest and build dependencies first for better caching
COPY Cargo.toml ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src

# Copy source and build the real binary
COPY src ./src
RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/trading-operator /usr/local/bin/trading-operator

USER 1000:1000

ENTRYPOINT ["/usr/local/bin/trading-operator"] 