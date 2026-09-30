#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")"
REPO_DIR="ev3dev-service-control"
IMAGE_NAME="sourceacademy/ev3-vala-compiler"

cd "$SCRIPT_DIR/$REPO_DIR"
# The ev3dev/debian-stretch-armel-cross base image's own /usr/bin/sudo is missing its setuid bit
# ("effective uid is not 0") - a defect in that specific image, not a runner/host issue: the
# sibling debian-stretch-cross image (Dockerfile.sling) uses the exact same sudo pattern and
# builds fine on the same runner. This image's default user genuinely isn't root either (a plain
# `sed -i` on /etc/apt/sources.list without sudo fails with a real permission error), so strip
# sudo AND force USER root directly - that doesn't depend on sudo's (broken) setuid mechanism at
# all. Patched here rather than in the upstream submodule repo, which we don't own.

# Debian Stretch has been end-of-life for years and its archive's Release-file signatures have
# since expired, so a plain `apt install -y` refuses to proceed ("unauthenticated packages"). This
# is the standard, narrowly-scoped workaround for an archived/dead release's own expired signing
# keys - it does not affect any live, currently-maintained repository.
sed -i \
  -e 's/^RUN sudo /RUN /' \
  -e 's/"sudo", //' \
  -e '/^FROM /a USER root' \
  -e 's/apt install --yes/apt -o APT::Get::AllowUnauthenticated=true install --yes/' \
  Dockerfile
docker build -t "$IMAGE_NAME" .

cd "$SCRIPT_DIR"
mkdir -p build-ev3/executables
docker run --rm  -v "$(realpath "$SCRIPT_DIR")":/src -w /src -u 0:0 "$IMAGE_NAME" -o build-ev3/executables/service_control "$REPO_DIR/main.vala"

# Clean up
docker rmi "$IMAGE_NAME"
