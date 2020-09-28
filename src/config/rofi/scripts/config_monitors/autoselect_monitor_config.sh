#!/usr/bin/env bash

function main()
{
	# Call menu
	selection=$(autorandr --detected | sort | head -n 1)

	if [[ -n $selection ]]; then
		autorandr $selection
	fi
}

main "$@"
