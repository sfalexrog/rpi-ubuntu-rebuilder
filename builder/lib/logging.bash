# Logging facilities for other functions

# Print out timestamped message
_log_time()
{
    printf "$(date '+[%Y-%m-%d %H:%M:%S]') %s\n" "$*" >&2;
}

# Print out 
log_info()
{
    printf '\e[1;34m' >&2
    _log_time "[INFO] $*"
    printf "\e[0m" >&2
}

log_err()
{
    printf '\e[1;31m' >&2
    _log_time "[ERROR] $*"
    printf "\e[0m" >&2
}
