#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0" )" && pwd )"
SRC_DIR="$SCRIPT_DIR/src/"

# directory to which config files with the same name of the ones present in this repository,
# if already present on system, will be moved
BACKUP_DIR="$SCRIPT_DIR/.bak/"
mkdir -p "$BACKUP_DIR"

# INSTALL_CACHE_FILE lists the dotfiles that have been properly "installed" 
# (i.e. that symlinks have been properly created)
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
			if [[ $? -eq 0 ]]; then
				ln -vs "$SRC_DIR/.config/$sub_dir" "$HOME/.config/$sub_dir"
				echo ".config/$sub_dir" >> "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"
			fi
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

		# if there is already a file with the same name in $HOME,
		# move it into the .bak directory
		if [[ -a "$HOME/$file" ]]; then
			mv -vi "$HOME/$file" "$BACKUP_DIR" 
		fi

		# if "mv" succeeded
		# create system link of the dotfile in $HOME
		if [[ $? -eq 0 ]]; then
			ln -vs "$SRC_DIR/$file" $HOME/$file
			echo "$file" >> "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"
		fi
	done

	if [[ ! "$(ls -A vim)" ]]; then
		git submodule update --init
	fi
	git submodule foreach git pull origin master
	vim/install.sh
}

function uninstall()
{
	for file in $(cat "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME")
	do
		# if is symlink, remove it
		if [[ -h "$HOME/$file" ]]; then
			rm "$HOME/$file"
		fi
		# bring back the original file
		if [[ -a "$BACKUP_DIR/$file" ]]; then
			mv -vi "$BACKUP_DIR/$file" "$HOME/$file"
		fi
	done
	
	# empty the file
	echo > "$SCRIPT_DIR/$INSTALL_CACHE_FILENAME"

	vim/install.sh --uninstall
}

function main()
{
	if [[ $1 == "--uninstall" ]]; then
		uninstall
	elif [[ $# -eq 0 ]]; then
		install
	fi
}

main "$@"
