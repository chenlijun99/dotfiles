#!/usr/bin/env bash

DIR="/tmp/chenlijun99/scripts/multiscreenshot/"

function take_screenshots()
{
	mkdir -p "${DIR}"
	rm -f "${DIR}/*"

	i=0

	flameshot gui --raw > "${DIR}/${i}.png"
	if [[ $? -ne 0 ]]; then
		return
	fi

	((i=i+1))

	xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease | while read -r line;
	do
		if [[ $line == *"detail"* ]]; then
			key=$( echo $line | sed "s/[^0-9]*//g")

			# Print key
			if [[ $key -eq 37 ]]; then
				echo $i
				flameshot gui --raw > "${DIR}/${i}.png"
				if [[ $? -ne 0 ]]; then
					rm "${DIR}/${i}.png"
					break
				fi
				((i=i+1))
			fi

			# Esc key
			if [[ $key -eq 9 ]]; then
				break
			fi
		fi
	done

	convert "${DIR}/*.png" -append png:- | xclip -selection clipboard -t image/png
	notify-send "chenlijun99 flameshot" "Concatenated screenshot saved to clipboard"
}

function main()
{
	flameshot config -t true

	take_screenshots

	flameshot config -t false
}

main "$@"
