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
Demonstrate option parsing feature in bash
Usage: $PROGRAM_NAME [OPTION...] FILE...

    -o FILE    Set output filename to FILE

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

output_filename=output.txt

while getopts ":hVo:D" opt; do
    case "$opt" in
        h)
            help_and_exit
            ;;
        V)
            version_and_exit
            ;;
        o)
            output_filename=$OPTARG
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

debug "output_filename=$output_filename"
debug "DEBUG=$DEBUG"

if [ "$#" -eq 1 ]; then
    error 1 "argument(s) required"
fi

for arg in "$@"; do
    echo "ARG: $arg"
done



        
