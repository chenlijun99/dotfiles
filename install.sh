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

		echo "Installing config files..."
		# ensure that $BACKUP_DIR exists
		mkdir -p "$BACKUP_DIR"
		install "$SCRIPT_DIR/src" "$HOME" "." "^(config|system|local|nixos)"
		install "$SCRIPT_DIR/src/config" "$HOME/.config" "" "^(ibus)"
		install "$SCRIPT_DIR/src/config/ibus/rime/" "$HOME/.config/ibus/rime"
		install "$SCRIPT_DIR/src/local/bin" "$HOME/.local/bin/"
		install "$SCRIPT_DIR/src/local/share/applications" "$HOME/.local/share/applications/"

		echo "Done."
	else
		echo "Usage: ./install.sh [--uninstall]"
	fi
}

main "$@"
