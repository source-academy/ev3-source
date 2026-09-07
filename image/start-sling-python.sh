#!/bin/bash

# Python's counterpart to start-sling.sh - runs entirely independently (own sling process, own
# SLING_DIR, own secret/device identity registered separately against the backend) so it can sit
# alongside the existing Source pipeline without touching it. See start-sling.sh's own comments for
# what each step below actually does; this only differs in which interpreter binary sling execs and
# which on-disk directory (hence which secret/device identity) it uses.

fatal_error() {
  >&2 echo $1
  exit 1
}

SLING_DIR="/var/lib/sling-python"
export SINTER_HOST_PATH="/usr/local/bin/pynter-ev3"
export SLING_PROGRAM_PATH="$SLING_DIR/program.pvm"
export SLING_KEY="$SLING_DIR/key.pem"
export SLING_CERT="$SLING_DIR/cert.pem"
export SLING_SECRET_FILE="$SLING_DIR/secret_b62"
export SLING_UUID_FILE="$SLING_DIR/secret"

if [ ! -f "$SLING_SECRET_FILE" ]; then
  uuidgen -r > "$SLING_UUID_FILE"
  uuidtob62 "$SLING_UUID_FILE" > "$SLING_SECRET_FILE"
fi

chmod 644 "$SLING_SECRET_FILE"

SLING_SECRET=$(cat "$SLING_SECRET_FILE")
SLING_BACKEND="https://api.sourceacademy.nus.edu.sg/v2/devices/$SLING_SECRET"

export SLING_HOST="$(curl -fs "$SLING_BACKEND/mqtt_endpoint")"
export SLING_DEVICE_ID="$(curl -fs "$SLING_BACKEND/client_id")"

if [ -z "$SLING_HOST" -o -z "$SLING_DEVICE_ID" ]; then
  fatal_error "Failed to get MQTT endpoint or MQTT client ID"
fi

curl -fs "$SLING_BACKEND/key" > "$SLING_KEY" || fatal_error "Failed to retrieve client key"
curl -fs "$SLING_BACKEND/cert" > "$SLING_CERT" || fatal_error "Failed to retrieve client certificate"

cd "$SLING_DIR"
exec /usr/local/bin/sling
