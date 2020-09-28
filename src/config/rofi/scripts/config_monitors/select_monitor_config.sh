#!/usr/bin/env bash

function main()
{
	# Call menu
	selection=$( autorandr --detected | sort | rofi -dmenu -p "Monitor Setup" )

	if [[ -n $selection ]]; then
		autorandr $selection
	fi
}

main "$@"
