#!/usr/bin/env bash
#
# Simple wrapper script of Alacritty.
#
# If Alacritty is executed with a command (i.e. using the -e option) but without
# a title, then the command is used as title.
#

if [[ $# -gt 0 ]]; then
	has_title=false
	command=""
	index=0
	for arg in "$@"
	do
		if [[ $arg == "-e" || $arg == "--command" ]]; then
			command=${*:index+2}
		fi
		if [[ $arg == "-t" || $arg == "--title" ]]; then
			has_title=true
		fi
		# Don't use increment `((index++))`, since if it evaluates to zero.
		# then the command "has failed". This doesn't work well if there
		# is `set -o errexit` set.
		# See https://unix.stackexchange.com/questions/276484/bash-set-o-errexit-problem-or-the-way-of-incrementing-variable
		index=$((index+1))
	done
	if [[ -n $command && "$has_title" == "false" ]]; then
		alacritty -t "$command - Alacritty" "$@"
	else
		alacritty "$@"
	fi
else
	alacritty "$@"
fi
