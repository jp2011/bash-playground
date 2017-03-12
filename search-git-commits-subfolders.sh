#!/bin/bash

BOLD="$(tput bold)"

for d in ./*/ ; do
	if ( cd "$d" && git log --oneline | grep "$1" ) ; then
		echo "${BOLD}$d${CLR}";
	fi
done