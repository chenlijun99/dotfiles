#!/usr/bin/env bash
#
# This script allows me to take multiple screenshots and then it vertically
# concatenates the indivual screenshots.
#

DIR="/tmp/chenlijun99/scripts/multiscreenshot"

function take_screenshots()
{
	mkdir -p "${DIR}"
	rm -fv "${DIR}"/*

	i=0

	active_window=$(xdotool getactivewindow)

	if ! flameshot gui --raw > "${DIR}/${i}.png" ; then
		return
	fi
	xdotool windowactivate "$active_window"

	((i=i+1))

	while read -r line;
	do
		notify-send "Press Ctrl to continue and Esc to terminate multiscreenshot.sh"
		if [[ $line == *"detail"* ]]; then
			# shellcheck disable=2001
			key=$( echo "$line" | sed "s/[^0-9]*//g")

			# Print key
			if [[ $key -eq 37 ]]; then
				active_window=$(xdotool getactivewindow)

				if ! flameshot gui --raw > "${DIR}/${i}.png"; then
					rm "${DIR}/${i}.png"
					break
				fi
				xdotool windowactivate "$active_window"
				((i=i+1))
			fi

			# Esc key
			if [[ $key -eq 9 ]]; then
				break
			fi
		fi
	done < <(xinput test-xi2 --root 3 | grep -A2 --line-buffered RawKeyRelease)

	convert "${DIR}/*.png" -append png:- | xclip -selection clipboard -t image/png
	notify-send "multiscreenshot.sh" "Concatenated screenshot saved to clipboard"
}

function main()
{
	tools=(xdotool xinput xclip flameshot)
	for tool in "${tools[@]}"
	do
		if ! command -v "$tool" > /dev/null; then
			notify-send "multiscreenshot.sh" "${tool} is not installed"
			exit
		fi
	done

	flameshot config -t true

	take_screenshots

	flameshot config -t false
}

main "$@"
