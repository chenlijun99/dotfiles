#!/usr/bin/env bash

. common.sh

function main()
{
	if [[ $1 == "--uninstall" ]]; then
		uninstall "$SCRIPT_DIR/src" "$HOME" "." "^(config)"
		uninstall "$SCRIPT_DIR/src/config" "$HOME/.config"
	elif [[ $# -eq 0 ]]; then
		echo "Pulling git submodules..."
		git submodule update --init

		echo "Installing rofi fonts..."
		# rofi widget fonts
		cp -n -r ./src/config/rofi/rofi/fonts/* ~/.local/share/fonts/

		echo "Installing config files..."
		# ensure that $BACKUP_DIR exists
		mkdir -p "$BACKUP_DIR"
		install "$SCRIPT_DIR/src" "$HOME" "." "^(config|system)"
		install "$SCRIPT_DIR/src/config" "$HOME/.config"

		echo "Done."
	else
		echo "Usage: ./install.sh [--uninstall]"
	fi
}

main "$@"
