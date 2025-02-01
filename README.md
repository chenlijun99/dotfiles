# My dotfiles

My current dotfiles is based on Nix and NixOS.

Getting started:

```sh
$ git clone https://github.com/chenlijun99/dotfiles --recursive
```

## NixOS

[src/nixos](./src/nixos/) contains my flake-based NixOS configuration.

To build the OS and switch to the new generation, run:

```sh
$ nixos-rebuild switch  --flake ./src/nixos#<config name>
```

To get list of available NixOS system generations, run:

```sh
$ nix-env --list-generations -p /nix/var/nix/profiles/system
```

To rollback to the previous generation, run

```sh
$ nixos-rebuild switch --rollback 
```

To revert to a specific system generation, run

```sh
$ nix-env --list-generations -p /nix/var/nix/profiles/system
```

To update flake inputs, run:

```sh
# Update one input
$ cd ./src/nixos/ && nix flake lock --update-input <input>
# Note that the --update-input can be also used with other `nix flake` commands.
# So you can also run
# This let's you update the flake and re-build the OS in one command
$ nixos-rebuild switch --flake ./src/nixos#<config name> --update-input <input>

# Update all the inputs
$ cd ./src/nixos/ && nix flake update
```

### Home manager

The provided NixOS configuration already integrates Home Manager. Every NixOS system selects which user to include (together with their home manager configuration).
But Home Manager can also be use standalone. To activate an user home configuration manually.

```sh
$ home-manager switch --flake ./src/nixos#<user>
```

This is useful when debugging home-manager specific Nix expressions.

### Build custom NixOS image

```sh
$ nix build ./src/nixos#<config name>
# E.g. build my VirtualBox
$ nix build ./src/nixos#virtualbox-guest
```

### Space optimization

```sh
# Delete all the old generations of all profiles and then perform GC.
# NOTE: "sudo" is necessary to delete NixOS generations
# Otherwise only unused packages, home-manager generations will be deleted.
$ sudo nix-collect-garbage -d
# Similar to the previous command, but deles only generations older than the given period
$ sudo nix-collect-garbage --delete-older-than <period>
```

See also:

* [Storage optimization - NixOS Wiki](https://nixos.wiki/wiki/Storage_optimization)

### Hardware (machine) config

```sh
# Generate or update machine-specific configuration
$ nixos-generate-config --dir src/nixos/machines/<machine name>
```

### Trouble-shooting

* Why is a derivation being built?

  Run `nix build` or whatever uses it (e.g. `nixos-rebuild switch`) with verbose logs (`--verbose`) and find the exact path of the derivation. Then find the top-level derivation (i.e. the system derivation or the home-manager derivation).

  ```sh
  $ nix why-depends <top-level derivation path> <derivation>
  ```

## Legacy

I now use NixOS, but I still try to keep things usable also on other distros. Here it is documented how my dotfiles used to work before the migration to NixOS.

### Installation

```sh
git clone https://github.com/chenlijun99/dotfiles --recursive
cd dotfiles
# Install dotfiles into $HOME, by creating system links.
./install.sh
```
Open a new shell.
