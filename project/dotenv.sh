#!/bin/bash
# Load env vars from $PWD/.env, then exec rest of command line.
#
# E.g. to run "ls -h" with the settings from .env loaded as env
# vars, do:
#
#   dotenv.sh ls -h
#
# in the directory where .env is.

if [ -e .env ] ; then
    # set -a -> all variables which are modified or created will be exported
    set -a
    source .env
fi

# Now exec the rest of the line, preserving quoting
exec "$@"
