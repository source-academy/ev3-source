#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")"
cd "$SCRIPT_DIR"

# pynter's own devices/ev3/build.sh is fully self-contained (its own Docker cross-compile image
# and CMake build), unlike sling/sinter_host which route through this repo's own toolchain image -
# so this just delegates rather than duplicating that pipeline.
"$SCRIPT_DIR/pynter/devices/ev3/build.sh"
