#!/bin/bash

# Run builder locally

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
SCRIPT_DIR_ABS="$(realpath "${SCRIPT_DIR}")"

# Prepare required images
docker pull multiarch/qemu-user-static
docker build -t image-builder docker

# Register multiarch support
# --privileged is required for binfmt_misc registration
docker run --rm --privileged multiarch/qemu-user-static -p yes

# Run build script
# --privileged is required for loopback device setup, chroot, etc
docker run -it --rm --privileged -v /dev:/dev -v "${SCRIPT_DIR_ABS}":/src -w /src \
  image-builder /src/builder/imgbuild.sh
