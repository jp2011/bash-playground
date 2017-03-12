#!/bin/bash

OLD_IFS="$IFS"
IFS=":"

for d in $PATH; do
	IFS="$OLD_IFS"
	p="$d/$1"
	if [ -f "$p" ]; then
		echo "$p"
	fi
done