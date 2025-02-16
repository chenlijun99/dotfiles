default:
	@just --list --justfile {{ justfile() }}

flakes-update:
	cd src/nixos && nix flae update

# NixOS Configuration
nixos-upgrade machine: flakes-update
	sudo nixos-rebuild switch --flake ./src/nixos#{{machine}}

nixos-rollback:
	nixos-rebuild switch --rollback 

nixos-list-generations:
	sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Home Manager
home-manager-upgrade user: flakes-update
	home-manager switch --flake ./src/nixos#{{user}}

# Space Optimization
nix-gc-delete-all:
	sudo nix-collect-garbage -d

# Space Optimization
nix-gc-delete-older period:
	sudo nix-collect-garbage --delete-older-than {{period}}

# Generate hardware-configuratio.nix for new machine
generate-machine-config machine:
	nixos-generate-config --dir src/nixos/machines/{{machine}}
