#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=lib/imgmount.bash
source "${SCRIPT_DIR}/lib/imgmount.bash"
# shellcheck source=lib/logging.bash
source "${SCRIPT_DIR}/lib/logging.bash"
# shellcheck source=lib/imgresize.bash
source "${SCRIPT_DIR}/lib/imgresize.bash"


IMAGE_URL="https://cdimage.ubuntu.com/releases/20.04.2/release/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz"
IMAGE_DIR="$(realpath "${SCRIPT_DIR}")/images"
IMAGE_ARCHIVE_NAME="$(basename ${IMAGE_URL})"
IMAGE_NAME="$(basename ${IMAGE_ARCHIVE_NAME} .xz)"

MOUNTPOINT="/mnt/ubntrpi"

if [ ! -f "${IMAGE_DIR}/${IMAGE_NAME}" ]; then
    if [ ! -f "${IMAGE_DIR}/${IMAGE_ARCHIVE_NAME}" ]; then
        log_info "Downloading ${IMAGE_URL} to ${IMAGE_DIR}"
        mkdir -p "${IMAGE_DIR}"
        wget "${IMAGE_URL}" -O "${IMAGE_DIR}/${IMAGE_ARCHIVE_NAME}"
    fi
    log_info "Unxzing ${IMAGE_ARCHIVE_NAME}"
    unxz -v "${IMAGE_DIR}/${IMAGE_ARCHIVE_NAME}"
fi

log_info "Resizing ${IMAGE_DIR}/${IMAGE_NAME} to 8G"

resize_img "${IMAGE_DIR}/${IMAGE_NAME}" 8G

log_info "Preparing image for mounting"

lodevice="$(mount_image "${IMAGE_DIR}/${IMAGE_NAME}" "${MOUNTPOINT}")"

log_info "Running in chroot"

chroot "${MOUNTPOINT}" uname -a

log_info "Unmounting chroot"

umount_image "${lodevice}" "${MOUNTPOINT}"
