#!/bin/bash

set -euxo pipefail

SCRIPT_DIR="$(dirname "$(realpath -s "${BASH_SOURCE[0]}")")"
cd "$SCRIPT_DIR"

cd image
cp ../build-ev3/{sling,sinter_host} .
cp ../pynter/devices/ev3/build-ev3/pynter-ev3 .
mkdir -p executables
cp ../build-ev3/executables/uuidtob62 executables

# Copy and rename our user executables
cp ../build-ev3/executables/show_qrcode executables/'Show QR Code'
cp ../build-ev3/executables/service_control executables/'Source Academy Settings'
cp kill_source.sh executables/'Kill Source Program'

docker build -t sourceacademy/ev3-source .

TMPDIR=$(mktemp -d)
TARFILE="$TMPDIR/ev3-source.tar"
IMGFILE="$TMPDIR/ev3-source.img"
OUTFILE="$SCRIPT_DIR/ev3-source.img.zip"

bash "$SCRIPT_DIR/brickstrap.sh" create-tar sourceacademy/ev3-source "$TARFILE"

docker rmi sourceacademy/ev3-source

export BRICKSTRAP_IMAGE_FILE_SIZE=$(echo $(($(du -m "$TARFILE" | cut -f1)*6/4+100)) | cut -d. -f1)M
echo 'Using BRICKSTRAP_IMAGE_FILE_SIZE='$BRICKSTRAP_IMAGE_FILE_SIZE

bash "$SCRIPT_DIR/brickstrap.sh" create-image "$TARFILE" "$IMGFILE"
rm "$TARFILE"

pushd "$TMPDIR"
zip -v "$OUTFILE" ev3-source.img
popd
rm -rf "$TMPDIR"
>&2 echo "Image created at $OUTFILE"
