#!/bin/sh
# Load env vars from $PWD/.env, then exec rest of command line.
#
# E.g. to run "ls -h" with the settings from .env loaded as env
# vars, do:
#
#   dotenv.sh ls -h
#
# in the directory where .env is.

if [ -e .env ] ; then
    # This one-liner from Peter Baumgartner and Yann Malet's
    # _High Performance Django_ (2014), page 21.
    export $(cat .env | grep -v ^# | xargs)
fi

# Now exec the rest of the line, preserving quoting
exec "$@"
