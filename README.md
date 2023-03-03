# My dotfiles

My current dotfiles is based on Nix and NixOS.

Getting started:

```sh
$ git clone https://github.com/chenlijun99/dotfiles --recursive
```

## To be improvement

* Make `?submodules=1` no more necessary.
    * Basically we need `?submodules=1` so that `nix` also fetches the submodules of our flake.
    * See more on [nix flakes: add support for git submodules - GitHub](https://github.com/NixOS/nix/issues/4423.)

## NixOS

[src/nixos](./src/nixos/) contains my flake-based NixOS configuration.

To build the OS, run:

```sh
$ nixos-rebuild switch  --flake ./src/nixos?submodules=1#<config name>
```

To update one of the flake inputs, run:

```sh
$ cd ./src/nixos/ && nix flake lock --update-input <input>
# Note that the --update-input can be also used with other `nix flake` commands.
# So you can also run
$ nixos-rebuild switch --flake ./src/nixos?submodules=1#<config name> --update-input <input>
# This let's you update the flake and re-build the OS in one command
```

### Home manager

The provided NixOS configuration already integrates Home Manager. Every NixOS system selects which user to include (together with their home manager configuration).
But Home Manager can also be use standalone. To activate an user home configuration manually.

```sh
$ home-manager switch --flake ./src/nixos?submodules=1#<user>
```

This is useful when debugging home-manager specific Nix expressions.

### Build custom NixOS image

```sh
$ nix build ./src/nixos#<config name>
# E.g. build my VirtualBox
$ nix build ./src/nixos#virtualbox-guest
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
