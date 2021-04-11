# Image resizing operations

# shellcheck source=logging.bash
source "$(dirname "${BASH_SOURCE[0]}")/logging.bash"

# Resize image and expand last (second) partition to fill it.
#
# Note that the image must not be mounted before calling this function.
resize_img()
{
    local image="$1"
    local size="$2"

    local lodevice

    if [ -z "${image}" ]; then
        log_err "Image name not specified"
        return 1
    fi

    if [ -z "${size}" ]; then
        log_err "Target size not specified"
        return 1
    fi

    log_info "Resizing ${image} to ${size}"

    truncate --size="${size}" "${image}"

    lodevice="$(losetup -Pf "${image}" --show)"

    log_info "Resizing partition #2 to the last sector"

    parted "${lodevice}" resizepart 2 -- -1s

    log_info "Running e2fsck on partition #2"

    e2fsck -f "${lodevice}p2"

    log_info "Extending partition #2"

    resize2fs "${lodevice}p2"

    log_info "Detaching loopback device ${lodevice}"

    losetup -d "${lodevice}"
}
