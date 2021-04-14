# Functions to simplify running scripts in a chroot

# shellcheck source=logging.bash
source "$(dirname "${BASH_SOURCE[0]}")/logging.bash"


# Run a script in a chroot environment
#
chroot_script()
{
    local mountpoint="$1"
    local script="$2"

    if [ ! -d "${mountpoint}" ]; then
        log_err "Mount point ${mountpoint} does not exist"
        return 1
    fi

    if [ ! -f "${script}" ]; then
        log_err "Script ${script} does not exist"
        return 1
    fi

    # Pass all other arguments to the script in chroot
    shift 2

    local script_tmpdir="${mountpoint}/tmp_script"
    local script_name
    script_name="$(basename "${script}")"

    log_info "Copying ${script} to ${script_tmpdir}"

    # Copy "library" scripts as well
    mkdir -p "${script_tmpdir}/lib"
    cp "${script}" "${script_tmpdir}"
    cp "$(dirname "${BASH_SOURCE[0]}")"/*.bash "${script_tmpdir}/lib"

    log_info "Preventing services from starting up"

    printf "#!/bin/sh\nexit101" > "${mountpoint}/usr/sbin/policy-rc.d"
    chmod a+x "${mountpoint}/usr/sbin/policy-rc.d"

    log_info "Running ${script} in ${mountpoint}"
    chmod a+x "${script_tmpdir}/${script_name}"
    chroot "${mountpoint}" /bin/bash -c "/tmp_script/${script_name} $*"

    log_info "Cleaning up"
    rm -rf "${script_tmpdir}"
    rm -f "${mountpoint}/usr/sbin/policy-rc.d"
}
