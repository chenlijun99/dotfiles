#!/bin/bash

# ignored files
BLACK_LIST=("." ".." "README.md" ".git" ".gitignore" ".gitmodules" ".backup" "install.sh" ".install_cache")
# .config and vim directory will be handle aside
BLACK_LIST+=(".config")
BLACK_LIST+=("vim")

# directory to which config files with the same name of the ones present in this repository,
# if already present on system, will be moved
BACKUP_DIR=".backup"
SCRIPT_DIR="$( cd "$(dirname "$0" )" && pwd )"


function handle_config_dir()
{
	if [[ -d "$SCRIPT_DIR/.config" ]]; then
		# AFAIK configuration dirs in .config are without leading dot,
		# thus plain ls should be enough to list all of them
		for sub_dir in $(ls "$SCRIPT_DIR/.config")
		do
			if [[ -d "$HOME/.config/$sub_dir" ]]; then
				if [[ ! -d "$SCRIPT_DIR/$BACKUP_DIR/.config" ]]; then
					mkdir "$SCRIPT_DIR/$BACKUP_DIR/.config"
				fi
				mv -vi "$HOME/.config/$sub_dir" "$SCRIPT_DIR/$BACKUP_DIR/.config"
			fi

			ln -s "$SCRIPT_DIR/.config/$sub_dir" "$HOME/.config/$sub_dir"
			echo ".config/$sub_dir" >> $SCRIPT_DIR/.install_cache
		done
	fi
}

function install()
{
	for file in $(ls -a1 $SCRIPT_DIR)
	do
		# check whether file is in BLACK_LIST. If true move directly to next iteration
		for element in ${BLACK_LIST[@]}
		do
			if [[ "$element" == "$file" ]]; then
				continue 2;
			fi
		done

		# if this file already exists in $HOME, move the file in $HOME into the .backup directory
		if [[ -a "$HOME/$file" ]]; then
			if [[ ! -d "$SCRIPT_DIR/$BACKUP_DIR" ]]; then
				mkdir "$SCRIPT_DIR/$BACKUP_DIR"
			fi
			mv -vi "$HOME/$file" "$SCRIPT_DIR/.backup"
		fi

		# create system link to dotfiles in repository in $HOME
		ln -s "$SCRIPT_DIR/$file" $HOME/$file

		# save a list of linked file, to ease the uninstalling
		echo "$file" >> "$SCRIPT_DIR/.install_cache"
	done

	handle_config_dir

	if [[ ! "$(ls -A vim)" ]]; then
		git submodule init
		git submodule update
	fi
	git submodule foreach git pull origin master
	vim/install.sh
}

function uninstall()
{
	for file in $(cat "$SCRIPT_DIR/.install_cache")
	do
		if [[ -h "$HOME/$file" ]]; then
			rm "$HOME/$file"
		fi
		if [[ -a "$SCRIPT_DIR/$BACKUP_DIR/$file" ]]; then
			mv -vi "$SCRIPT_DIR/$BACKUP_DIR/$file" "$HOME/$file"
		fi
	done
	echo > "$SCRIPT_DIR/.install_cache"

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
