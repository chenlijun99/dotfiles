#!/usr/bin/env bash

. common.sh

function main()
{
	if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
		exit
	fi

	if [[ $1 == "--uninstall" ]]; then
		uninstall "$SCRIPT_DIR/src" "$HOME" "." "^(config)"
		uninstall "$SCRIPT_DIR/src/config" "$HOME/.config"
	elif [[ $# -eq 0 ]]; then
		echo "Installing udev rules"
		install "$SCRIPT_DIR/src/system/udev/" "/etc/udev/rules.d/"
		udevadm control --reload

		echo "Done."
	else
		echo "Usage: ./install_system.sh [--uninstall]"
	fi
}

main "$@"
