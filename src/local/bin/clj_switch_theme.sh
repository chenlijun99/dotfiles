#!/usr/bin/env bash
#
# This script is deeply coupled with how I configured alacritty and neovim.
# I use this script to switch between light mode and dark mode.
#

if [ "$#" -eq 1 ]; then
	ALACRITTY_CONFIG_PATH="$HOME/.config/alacritty/";
	ALACRITTY_DATA_PATH="$HOME/.local/share/alacritty";
	mkdir -p "$ALACRITTY_DATA_PATH"
	if [[ "$1" == "dark" ]]; then
		ln -sf "$ALACRITTY_CONFIG_PATH"/gruvbox_dark.yaml "$ALACRITTY_DATA_PATH"/clj_current_theme.yaml
		echo "Changed Alacritty theme to gruvbox_dark"
	fi
	if [[ "$1" == "light" ]]; then
		ln -sf "$ALACRITTY_CONFIG_PATH"/gruvbox_light.yaml "$ALACRITTY_DATA_PATH"/clj_current_theme.yaml
		echo "Changed Alacritty theme to gruvbox_light"
	fi
else
	echo "Usage: $0 <dark|light>"
	exit 1
fi
