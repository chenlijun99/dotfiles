#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0" )" && pwd )"
SRC_DIR="$SCRIPT_DIR/src"
# directory in which config files with the same name of the ones present in this repository,
# if already present, will be moved
BACKUP_DIR="$SCRIPT_DIR/.bak"
# INSTALL_CACHE_FILE lists the dotfiles that have been properly "installed" 
# (i.e. symlinks have been properly created)
# This file comes handy when uninstalling
INSTALL_CACHE_FILENAME=".install_cache"

function install_config_dir()
{
	if [[ -d "$SRC_DIR/.config" ]]; then
		# AFAIK configuration dirs in .config are without leading dot,
		# thus plain ls should be enough to list all them
		for sub_dir in $(ls "$SRC_DIR/.config")
		do
			if [[ -d "$HOME/.config/$sub_dir" ]]; then
				mkdir -p "$BACKUP_DIR/.config"
				mv -vi "$HOME/.config/$sub_dir" "$BACKUP_DIR/.config"
			fi
			ln -vs "$SRC_DIR/.config/$sub_dir" "$HOME/.config/$sub_dir"
			echo ".config/$sub_dir" >> "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"
		done
	fi
}

function install()
{
	for file in $(ls -A1 "$SRC_DIR")
	do
		# handle .config dir separately
		if [[ $file == ".config" ]]; then
			install_config_dir
			continue
		fi

		# if there is already a regular file with the same name in $HOME,
		# move it into the .bak directory
		if [[ -f "$HOME/$file" || (-h "$HOME/$file" && $(realpath "$HOME/$file") != "$SRC_DIR/$file") ]]; then
			mv -vi "$HOME/$file" "$BACKUP_DIR" 
		fi

		ln -vs "$SRC_DIR/$file" $HOME/$file
		# mark that the file has been successfully "installed"
		echo "$file" >> "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"
	done
}

function uninstall()
{
	for file in $(cat "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME")
	do
		# if is symlink, remove it
		if [[ -h "$HOME/$file" && $(realpath "$HOME/$file") == "$SRC_DIR/$file" ]]; then
			rm -v "$HOME/$file"
		fi
		# bring back the original file
		if [[ -a "$BACKUP_DIR/$file" ]]; then
			mv -vi "$BACKUP_DIR/$file" "$HOME/$file"
		fi
	done

	# empty the file
	echo > "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"
}

function main()
{
	if [[ $1 == "--uninstall" ]]; then
		uninstall
	elif [[ $# -eq 0 ]]; then
		# ensure that $BACKUP_DIR exists
		mkdir -p "$BACKUP_DIR"
		install
	fi
}

main "$@"
