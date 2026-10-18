#!/usr/bin/env bash
set -e

# Default daemon runner with automatic fallback to interactive auth
run_remote_daemon() {
    # Try launching the background daemon
    if agy remote-control serve; then
        exit 0
    fi

    # If serve failed (e.g. not signed in yet), launch agy with --remote-control.
    # This initiates the authentication flow, prints the sign-in URL into stdout / container logs,
    # and keeps the session active via Remote Control once authenticated.
    echo ""
    echo "=========================================================================="
    echo " Daemon not signed in. Launching Antigravity CLI to authenticate..."
    echo " Check container logs for the sign-in URL or connect via container console."
    echo "=========================================================================="
    echo ""
    exec agy --remote-control
}

# If no arguments provided, run remote daemon flow
if [ "$#" -eq 0 ]; then
    run_remote_daemon
fi

# If default CMD ["agy", "remote-control", "serve"] was invoked, run remote daemon flow
if [ "$1" = "agy" ] && [ "$2" = "remote-control" ] && [ "$3" = "serve" ] && [ "$#" -eq 3 ]; then
    run_remote_daemon
fi

# If first argument starts with a dash (e.g. -p, --version, --help), pass to agy
if [ "${1:0:1}" = '-' ]; then
    exec agy "$@"
fi

# If first argument is agy, execute directly
if [ "$1" = 'agy' ]; then
    exec "$@"
fi

# Otherwise, execute user-provided command (e.g. bash, sh, etc.)
exec "$@"
