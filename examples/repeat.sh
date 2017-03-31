#!/bin/bash

PROGRAM_NAME=$(basename "$0")
VERSION_STRING="0.1"
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

help_and_exit() {
    cat <<EOF
Execute a command repeatedly
Usage: $PROGRAM_NAME [OPTION...] REPEAT-COUNT COMMAND...

    -f         Force repetition even if COMMAND failed with nonzero exit status

    -D         verbose messages for debugging purpose

    -h         show help message and exit
    -V         display version information and exit

EOF
    exit 0
}

version_and_exit() {
    echo "$PROGRAM_NAME version $VERSION_STRING"
    exit 0
}

option_keepgoing=0

while getopts ":hVDf" opt; do
    case "$opt" in
        h)
            help_and_exit
            ;;
        V)
            version_and_exit
            ;;
        f)
            option_keepgoing=1
            ;;
        \?)
            error 0 "unrecognized option -- '$OPTARG'"
            error 1 "Try with '-h' for more"
            ;;
        D)
            DEBUG=1
            ;;
    esac
done

shift $((OPTIND - 1))
debug "args: $*"

if [ "$#" -lt 2 ]; then
    error 1 "Wrong number of argument(s)"
fi

COUNT="$1"
debug "count: $COUNT"
shift

while [ "$COUNT" -gt 0 ]; do
    "$@"
    exitcode="$?"
    debug "exit code $exitcode: $*"
    
    if [ "$option_keepgoing" -eq 0 -a "$exitcode" -ne 0 ]; then
        exit "$exitcode"
    fi
    COUNT=$((COUNT - 1))
done



        
