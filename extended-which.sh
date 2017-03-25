#!/bin/bash

EXTENDED_PATH="${PATH}:/home/jp200"
IFS=":"


for d in $EXTENDED_PATH; do
	p="$d/$1"
	if [ -f "$p" ]; then
		echo "$p"
        exit 0
	fi
done
exit 1