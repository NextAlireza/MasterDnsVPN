#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/app"
cd "$APP_DIR"

# Find the binary
EXECUTABLE="$(ls -t MasterDnsVPN_Server_Linux_*_v* 2>/dev/null | head -n1 || true)"
if [[ -z "$EXECUTABLE" ]]; then
  echo "[ERROR] Binary not found in $APP_DIR"
  exit 1
fi
chmod +x "$EXECUTABLE"

# Generate encryption key if not exists
if [[ ! -f "encrypt_key.txt" ]]; then
  echo "[INFO] Generating encryption key..."
  ./"$EXECUTABLE" -genkey -nowait 2>/dev/null || {
    # Fallback for older versions
    ./"$EXECUTABLE" &
    APP_PID=$!
    for i in $(seq 1 10); do
      [[ -f "encrypt_key.txt" ]] && break
      sleep 1
    done
    kill "$APP_PID" 2>/dev/null || true
    wait "$APP_PID" 2>/dev/null || true
  }
  echo "[INFO] Encryption key: $(cat encrypt_key.txt 2>/dev/null)"
fi

# If Railway provides a PORT, note it (DNS still uses 53 internally)
echo "[INFO] Starting MasterDnsVPN server..."
echo "[INFO] Binary: $EXECUTABLE"
echo "[INFO] Config: $APP_DIR/server_config.toml"

exec ./"$EXECUTABLE"
