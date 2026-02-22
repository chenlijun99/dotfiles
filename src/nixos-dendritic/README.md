# Nix Configuration

My multi-device NixOS/Darwin/Home-Manager configuration using the [Dendritic Pattern](https://github.com/mightyiam/dendritic) with [Flake Parts](https://flake.parts/).

## Usage

```bash
# Build NixOS configuration
$ sudo nixos-rebuild switch --flake .#clj-host-bosgame-m5

# Build and run NixOS configuration in a VM
$ nixos-rebuild build-vm --flake ./src/nixos-dendritic#clj-host-bosgame-m5
$ ./result/bin/run-clj-host-bosgame-m5-vm

# Build Darwin configuration
$ darwin-rebuild switch --flake .#clj-host-macbook-pro-m4-max
```

See also [`examples/incus-dev-vm/flake.nix`](./examples/incus-dev-vm/) for an example of how the modules defined here can be reused in another flake.

## Why Dendritic?

Advantages:

* Modules as Flake Outputs: All modules are exposed via `flake.modules.<class>.<name>`, making them trivially reusable in other flakes. This is useful for keeping private configurations that shouldn't live in a public repository - just import this flake and compose!
* High Cohesion: Everything about a feature (NixOS settings, Darwin settings, Home-Manager config) lives in one place. No more hunting across scattered files when debugging or extending a feature.

## Design Decisions

**No flake-file**: Unlike some dendritic setups, I intentionally keep `flake.nix` as the single source of truth for inputs. I prefer:

* All inputs visible in one place
* Manual control over `inputs.*.follows`
* No generated files to keep in sync

**Module Prefix**: All first-party modules use the `clj-` prefix (e.g., `clj-neovim`, `clj-performance`) to clearly distinguish them from upstream modules.

**Separation of Concerns**:

* `modules/` - Reusable modules meant also for external flakes to import
* `hosts/` - Host-specific configurations (outputs of this flake, not for reuse)

## Module Dependencies

**Important**: Most Home-Manager feature modules (`clj-neovim`, `clj-shell`, `clj-git`, etc.) depend on `clj-lib` to provide the `config.lib.clj.linkDotfile` function. You have two options:

1. **Use a preset** (recommended): Presets like `clj-preset-minimal` and `clj-preset-full` automatically include `clj-lib` and all necessary dependencies.

   ```nix
   imports = [dotfiles.modules.homeManager.clj-preset-minimal];
   ```

2. **Import `clj-lib` explicitly**: When using individual feature modules, you must import `clj-lib` first:

   ```nix
   imports = [
     dotfiles.modules.homeManager.clj-lib
     dotfiles.modules.homeManager.clj-neovim
     dotfiles.modules.homeManager.clj-shell
   ];
   ```

**Why not auto-import?** Due to a [limitation in NixOS/nixpkgs#340361](https://github.com/NixOS/nixpkgs/issues/340361), importing the same flake-based module multiple times causes "option already declared" errors. Having feature modules import `clj-lib` themselves would cause conflicts when using presets.

## Impermanence

The `clj-impermanence` module provides integration with [nix-community/impermanence](https://github.com/nix-community/impermanence) for systems with ephemeral root filesystems.

Persistent directories are pre-configured based on common needs (SSH, GPG, browser data, development directories, etc.).
