# My dotfiles

My current dotfiles is based on Nix and NixOS.

Getting started:

```sh
git clone https://github.com/chenlijun99/dotfiles --recursive
```

## NixOS

[src/nixos](./src/nixos/) contains my flake-based NixOS configuration.

Use `just` recipes.

### Home manager

The provided NixOS configuration already integrates Home Manager. Every NixOS system selects which user to include (together with their home manager configuration).
But Home Manager can also be use standalone. To activate an user home configuration manually.

In NixOS this is useful when debugging home-manager specific Nix expressions.

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
