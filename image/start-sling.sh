#!/bin/bash

fatal_error() {
  >&2 echo $1
  exit 1
}

# Prod and stg are separate deployments with separate device databases and separate AWS IoT
# brokers - a device paired through one is invisible to, and holds no live connection on, the
# other. There's no single "right" backend to hardcode: whichever frontend a user is testing from
# expects the device connected to *that* backend's broker specifically. So instead of picking one,
# this script is parametrized by backend host and run as two independent, concurrently-running
# services (see sling.service / sling-stg.service) - the device ends up genuinely live on both at
# once.
BACKEND_HOST="$1"
if [ -z "$BACKEND_HOST" ]; then
  fatal_error "Usage: start-sling.sh <backend-host>"
fi

SLING_DIR="/var/lib/sling"
export SINTER_HOST_PATH="/usr/local/bin/sinter_host"
export SLING_SECRET_FILE="$SLING_DIR/secret_b62"
export SLING_UUID_FILE="$SLING_DIR/secret"

if [ ! -f "$SLING_SECRET_FILE" ]; then
  uuidgen -r > "$SLING_UUID_FILE"
  uuidtob62 "$SLING_UUID_FILE" > "$SLING_SECRET_FILE"
fi

chmod 644 "$SLING_SECRET_FILE"

SLING_SECRET=$(cat "$SLING_SECRET_FILE")

# Each backend issues its own cert/key pair (and would hand back its own program.svm state) for
# this device's secret, so each backend gets its own subdirectory here rather than sharing
# SLING_DIR's files directly - otherwise the prod and stg instances running concurrently would
# clobber each other's credentials and in-flight program.
CREDS_DIR="$SLING_DIR/$(echo "$BACKEND_HOST" | sed -E 's|https?://||; s|[^A-Za-z0-9]+|-|g')"
mkdir -p "$CREDS_DIR"
export SLING_PROGRAM_PATH="$CREDS_DIR/program.svm"
export SLING_KEY="$CREDS_DIR/key.pem"
export SLING_CERT="$CREDS_DIR/cert.pem"

SLING_BACKEND="$BACKEND_HOST/v2/devices/$SLING_SECRET"

export SLING_HOST="$(curl -fs "$SLING_BACKEND/mqtt_endpoint")"
export SLING_DEVICE_ID="$(curl -fs "$SLING_BACKEND/client_id")"

if [ -z "$SLING_HOST" -o -z "$SLING_DEVICE_ID" ]; then
  fatal_error "Failed to get MQTT endpoint or MQTT client ID from $BACKEND_HOST"
fi

curl -fs "$SLING_BACKEND/key" > "$SLING_KEY" || fatal_error "Failed to retrieve client key"
curl -fs "$SLING_BACKEND/cert" > "$SLING_CERT" || fatal_error "Failed to retrieve client certificate"

cd "$CREDS_DIR"
exec /usr/local/bin/sling
