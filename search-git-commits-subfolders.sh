#!/bin/bash

BOLD="$(tput bold)"
STANDOUT="$(tput smso)"
CLR="$(tput sgr0)"
BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"


# set -o pipefail  # this makes sure that if any of the commands in the pipeline fail, that error code will be returned

for d in ./*/ ; do
	if ( cd "$d" && git log --oneline | grep "$1" ) ; then
		echo "${BOLD}$d${CLR}";
	fi
done