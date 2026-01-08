default:
	@just --list --justfile {{ justfile() }}

# Update project devenv
update:
	devenv update

flakes-update:
	cd src/nixos && nix flake update

nixos-switch machine:
	sudo nixos-rebuild switch --flake ./src/nixos#{{machine}}

darwin-switch host:
	sudo $(which darwin-rebuild) switch --flake ./src/nixos#{{host}}

nixos-rollback:
	nixos-rebuild switch --rollback 

nixos-list-generations:
	sudo nix-env --list-generations -p /nix/var/nix/profiles/system

home-manager-switch user:
	home-manager switch --flake ./src/nixos#{{user}}

secrets-user-gen-key ssh_private_key:
	mkdir -p ~/.config/sops/age/
	ssh-to-age -private-key -i {{ssh_private_key}} > ~/.config/sops/age/keys.txt
	echo "Add the following age key to .sops.yaml"
	ssh-to-age -i {{ssh_private_key}}.pub

secrets-list:
	#!/usr/bin/env bash

	# Check if .sops.yaml exists
	if [ ! -f ".sops.yaml" ]; then
	  echo "Error: .sops.yaml not found" >&2
	  exit 1
	fi

	# Extract regexes
	regexes=$(cat .sops.yaml | yq -r '.creation_rules[].path_regex' | sed 's/^"//; s/"$//' | tr '\n' '|')

	# Remove the trailing pipe character
	regexes="${regexes%|}"

	# Find files and filter with ripgrep
	find . -type f | rg --color never --regexp "$regexes"

secrets-edit:
	#!/usr/bin/env bash
	SELECTED_SECRET_FILE=$(just secrets-list | fzf)
	sops "$SELECTED_SECRET_FILE"

secrets-update:
	#!/usr/bin/env bash
	for SECRET_FILE in $(just secrets-list); do
		sops updatekeys "$SECRET_FILE"
	done

# Space Optimization
# nix-collect-garbage with sudo cleans system garbage, without sudo cleans
# per-user garbage
#
nix-gc-delete-all:
	sudo nix-collect-garbage -d && nix-collect-garbage -d

nix-gc-delete-older period:
	sudo nix-collect-garbage --delete-older-than {{ period }} && nix-collect-garbage --delete-older-than {{ period }}

# Generate hardware-configuratio.nix for new machine
generate-machine-config machine:
	nixos-generate-config --dir src/nixos/machines/{{machine}}
