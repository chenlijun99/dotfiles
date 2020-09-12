#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "$0" )" && pwd )"
BACKUP_DIR="$SCRIPT_DIR/.bak"

##
# For each file in source_dir, create a symbolic link in destination_dir 
# which points to it (if exists).

# Globals:
#	BACKUP_DIR: backup directory where already existing file will be copied, so as to
#   allow symbolic to be created
# Arguments:
#	source_dir: the directory for which you want to create symbolic links to all it's files
#	destination_dir: the directory in which the symbolic links will be created
#	prepend: string that will be prepended to the symbolic link's name
#	exclude: don't create symbolic link for files in source_dir matching the exclude regex
# Returns:
#	None
function install()
{
	local source_dir="$1"
	local destination_dir="$2"
	local prepend="$3"
	local exclude="$4"

	for file in $(ls -A1 "$source_dir")
	do
		# ignore if exclude regex is defined and file matches it.
		if [[ (! -z $exclude) && $file =~ $exclude ]]; then
			continue
		fi

		source="$source_dir/$file"
		target="$destination_dir/$prepend$file"

		# Move only if the target file is a normal file or directory
		# or, if it's a system link, only if the link points to a different location
		if [[ ( ! -h "$target" && ( -f "$target" || -d "$target") ) || \
			(-h "$target" && $(realpath "$target") != $(realpath "$source")) ]]; then
			mv -vi "$target" "$BACKUP_DIR/$file"
		fi

		# If the target file doesn't exists, which means either that it's not
		# present on the current system or that it has been properly backed up,
		# proceed with link creation.
		if [[ ! (-a "$target") ]]; then
			ln -vs "$source" "$target"
		fi
	done
}

##
# For each file in source_dir, remove the symbolic link in destination_dir 
# which points to it (if exists).
#
# Globals:
#	BACKUP_DIR: backup directory where already existing file have been copied, so as to
#   allow symbolic to be created. They will be restored
# Arguments:
#	source_dir: the directory containg files referenced by symbolic links in destination_dir
#	destination_dir: the directory in which the symbolic links have been created
#	prepend: string have been prepended to the symbolic link's name
#	exclude: don't remove symbolic link for files in source_dir matching the exclude regex
# Returns:
#	None
function uninstall()
{
	local source_dir="$1"
	local destination_dir="$2"
	local prepend="$3"
	local exclude="$4"

	for file in $(ls -A1 "$source_dir")
	do
		if [[ (! -z $exclude) && $file =~ $exclude ]]; then
			continue
		fi

		source="$source_dir/$file"
		target="$destination_dir/$prepend$file"
		backup="$BACKUP_DIR/$prepend$file"

		if [[ (-h "$target" && $(realpath "$target") == $(realpath "$source")) ]]; then
			rm $target
		fi

		if [[ -a "$backup" ]]; then
			mv "$backup" "$target"
		fi
	done
}

function main()
{
	if [[ $1 == "--uninstall" ]]; then
		uninstall "$SCRIPT_DIR/src" "$HOME" "." "^(config)"
		uninstall "$SCRIPT_DIR/src/config" "$HOME/.config"
	elif [[ $# -eq 0 ]]; then
		# ensure that $BACKUP_DIR exists
		mkdir -p "$BACKUP_DIR"
		install "$SCRIPT_DIR/src" "$HOME" "." "^(config)"
		install "$SCRIPT_DIR/src/config" "$HOME/.config"
	else
		echo "Usage: ./install.sh [--uninstall]"
	fi
}

main "$@"
