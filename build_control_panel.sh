#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")"
REPO_DIR="ev3dev-service-control"
IMAGE_NAME="sourceacademy/ev3-vala-compiler"

cd "$SCRIPT_DIR/$REPO_DIR"
# Strip `sudo` from the Dockerfile before building: the base image runs as root by default (this
# repo always invokes it with -u 0:0 below, and never anything else), so sudo was never load-bearing
# there - just carried over unmodified from the StackOverflow snippet its top RUN line cites. It
# fails outright on GitHub's newer runner images: their Docker host mounts each RUN step's rootfs
# nosuid, which strips sudo's setuid bit ("effective uid is not 0"), regardless of BuildKit vs the
# legacy builder - patched here rather than in the upstream submodule repo, which we don't own.
sed -i -e 's/^RUN sudo /RUN /' -e 's/"sudo", //' Dockerfile
docker build -t "$IMAGE_NAME" .

cd "$SCRIPT_DIR"
mkdir -p build-ev3/executables
docker run --rm  -v "$(realpath "$SCRIPT_DIR")":/src -w /src -u 0:0 "$IMAGE_NAME" -o build-ev3/executables/service_control "$REPO_DIR/main.vala"

# Clean up
docker rmi "$IMAGE_NAME"
