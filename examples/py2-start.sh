#!/bin/bash

PROGRAM_NAME=$(basename "$0")
DEBUG=0

error() {
    local ecode="$1"
    shift
    echo "$PROGRAM_NAME: $*" 1>&2
    [ "$ecode" -ne 0 ] && exit "$ecode"
}

debug() {
    if [ "$DEBUG" -ne 0 ]; then
        echo "debug: $*" 1>&2
    fi
}


PYEXE=$(which python 2>/dev/null)

if [ ! -x "$PYEXE" ]; then
    error 1 "Python required"
else
    if ! "$PYEXE" --version 2>&1 | grep ' 2\.[0-9]' >/dev/null; then
        error 1 "Python 2.x required"
    fi
fi


"$PYEXE" <(cat <<EOF
import sys

print "VERSION: %s" % repr(sys.version_info)
print "ARGV: %s" % sys.argv
EOF
          ) "$@"

