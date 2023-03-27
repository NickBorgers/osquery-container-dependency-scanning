FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y binutils wget && rm -rf /var/lib/apt/lists/*