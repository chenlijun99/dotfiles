#!/usr/bin/env bash
#
# This script is deeply coupled with how I configured alacritty and neovim.
# I use this script to switch between light mode and dark mode.
#

#
# @param desired_theme "dark" or "light"
#
function generate_set_background_vimscript() {
	local desired_theme="$1"

	cat <<-END
		if &background != '${desired_theme}'
		  set background=${desired_theme}
		endif
	END
}

if [ "$#" -eq 1 ]; then
	ALACRITTY_CONFIG_PATH="$HOME/.config/alacritty/"
	ALACRITTY_DATA_PATH="$HOME/.local/share/alacritty"

	NEOVIM_DATA_PATH="$HOME/.local/share/nvim"
	NEOVIM_COLORSCHEME_DATA_PATH="${NEOVIM_DATA_PATH}/clj/colorscheme.vim"

	mkdir -p "$ALACRITTY_DATA_PATH"
	if [[ "$1" == "dark" ]]; then
		ln -sf "$ALACRITTY_CONFIG_PATH"/gruvbox_dark.yaml "$ALACRITTY_DATA_PATH"/clj_current_theme.yaml
		echo "Changed Alacritty theme to gruvbox_dark"

		generate_set_background_vimscript "dark" >"$NEOVIM_COLORSCHEME_DATA_PATH"
		echo "Changed Neovim theme to gruvbox_dark"
	elif [[ "$1" == "light" ]]; then
		ln -sf "$ALACRITTY_CONFIG_PATH"/gruvbox_light.yaml "$ALACRITTY_DATA_PATH"/clj_current_theme.yaml
		echo "Changed Alacritty theme to gruvbox_light"

		generate_set_background_vimscript "light" >"$NEOVIM_COLORSCHEME_DATA_PATH"
		echo "Changed Neovim theme to gruvbox_light"
	else
		echo "Invalid value $1"
	fi
else
	echo "Usage: $0 <dark|light>"
	exit 1
fi
