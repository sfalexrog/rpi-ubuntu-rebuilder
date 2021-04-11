# Image mounting utilities

# shellcheck source=logging.bash
source "$(dirname "${BASH_SOURCE[0]}")/logging.bash"

# Mount everything needed to chroot into the image
# 
mount_image() {
    local image="$1"
    local mountroot="$2"
    if [ -z "${image}" ]; then
        log_err "No image file specified"
        return 1
    fi

    if [ -z "${mountroot}" ]; then
        log_err "No mount point specified"
        return 1
    fi

    if [ ! -f "${image}" ]; then
        log_err "Image file does not exist"
    fi

    log_info "Mounting ${image} to ${mountroot}"

    mkdir -p "${mountroot}"

    local img_device
    img_device="$(losetup -Pf "${image}" --show)"
    log_info "Received ${img_device} as loopback device"
    # FIXME: parse fstab?
    mount "${img_device}p2" "${mountroot}"
    mount "${img_device}p1" "${mountroot}/boot/firmware"

    mount -t proc proc "${mountroot}/proc"
    mount -t sysfs sysfs "${mountroot}/sys"
    mount -o bind /dev "${mountroot}/dev"
    mount -o bind /dev/pts "${mountroot}/dev/pts"
    mount -o bind /run "${mountroot}/run"

    mv "${mountroot}/etc/resolv.conf" "${mountroot}/etc/resolv.conf.bak"

    cp -L /etc/resolv.conf "${mountroot}/etc/resolv.conf" || true

    echo "${img_device}"
}

# Unmount chroot and clean up lodevice
#
umount_image() {
    local lodevice="$1"
    local mountroot="$2"

    if [ -z "${lodevice}" ]; then
        log_err "No loopback device specified"
        return 1
    fi

    if [ ! -b "${lodevice}" ]; then
        log_err "Loopback device ${lodevice} does not exist or is not a block device"
        return 1
    fi

    if [ -z "${mountroot}" ]; then
        log_err "No mount point specified"
        return 1
    fi

    if [ ! -d "${mountroot}" ]; then
        log_err "Mount point ${mountroot} does not exist or is not a directory"
        return 1
    fi

    log_info "Restoring original resolv.conf"

    rm -f "${mountroot}/etc/resolv.conf"
    mv "${mountroot}/etc/resolv.conf.bak" "${mountroot}/etc/resolv.conf"

    log_info "Unmounting ${mountroot} and removing backing device ${lodevice}"

    local umount_ok="false"

    for i in {1..5}; do
        if umount -fR "${mountroot}" ; then
            umount_ok="true"
            break
        else
            log_err "Failed to unmount mountpoint (try ${i} out of 5); ${mountroot} still in use by the following processes: "
            lsof +D "${mountroot}" >&2; sleep 2
        fi
    done

    if [ "${umount_ok}" = "true" ]; then
        log_info "Unmounted ${mountroot}"
        losetup -d "${lodevice}"
        log_info "Removed ${lodevice}"
    else
        log_err "Could not unmount mountpoint, giving up"
        return 1
    fi
}
