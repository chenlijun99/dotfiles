#!/usr/bin/env bash

. common.sh

function main()
{
	echo "Installing nixos config..."
	# ensure that $BACKUP_DIR exists
	mkdir -p "$BACKUP_DIR"
	install "$SCRIPT_DIR/src/nixos/" "/etc/nixos/"

	echo "Done."
}

main "$@"
