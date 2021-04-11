#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=lib/logging.bash
source "${SCRIPT_DIR}/lib/logging.bash"


some_func_that_will_perform_stdout() {
    log_info "Running in a Bash function"
    log_info "My arguments are: $*"

    echo "some value"
}

lodevice="$(some_func_that_will_perform_stdout /dev/video0 /mnt/nothing)"

echo "function returned: ${lodevice}"
