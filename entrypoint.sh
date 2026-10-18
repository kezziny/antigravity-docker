#!/usr/bin/env bash
set -e

# If no arguments are provided, launch agy directly
if [ "$#" -eq 0 ]; then
    exec agy
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
