FROM debian:bookworm-slim

LABEL maintainer="masterking32"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget unzip ca-certificates \
    iproute2 procps lsof net-tools \
    && rm -rf /var/lib/apt/lists/*

# Detect architecture
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64|amd64)  PKG="MasterDnsVPN_Server_Linux_AMD64" ;; \
      aarch64|arm64) PKG="MasterDnsVPN_Server_Linux_ARM64" ;; \
      armv7l|armv7)  PKG="MasterDnsVPN_Server_Linux_ARMV7" ;; \
      *) echo "Unsupported arch: $ARCH" && exit 1 ;; \
    esac && \
    echo "Downloading: $PKG" && \
    curl -fL --retry 3 -o /tmp/server.zip \
      "https://github.com/masterking32/MasterDnsVPN/releases/latest/download/${PKG}.zip" && \
    unzip -q -o /tmp/server.zip -d /app && \
    rm -f /tmp/server.zip && \
    chmod +x /app/MasterDnsVPN_Server_Linux_*

WORKDIR /app

# Copy entrypoint
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# Railway assigns a random port via $PORT env var
# MasterDnsVPN listens on 53 by default; we map it in entrypoint
EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/app/docker-entrypoint.sh"]
