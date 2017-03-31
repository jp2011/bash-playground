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


RBEXE=$(which ruby 2>/dev/null)

if [ ! -x "$RBEXE" ]; then
    error 1 "Ruby required"
else
    if ! "$RBEXE" --version 2>&1 | grep ' 2\.[0-9]' >/dev/null; then
        error 1 "Ruby 2.x required"
    fi
fi


"$RBEXE" <(cat <<EOF
puts "VERSION: #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"
puts "ARGV: #{ARGV}"
EOF
          ) "$@"

