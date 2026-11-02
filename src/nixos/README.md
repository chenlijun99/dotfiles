# Nix Configuration

My multi-device NixOS/Darwin/Home-Manager configuration using the [Dendritic Pattern](https://github.com/mightyiam/dendritic) with [Flake Parts](https://flake.parts/).

## Usage

This flake exports reusable NixOS, nix-darwin, and Home Manager modules. Host
configurations live in the private homelab repository.

See [`examples/incus-dev-vm/flake.nix`](./examples/incus-dev-vm/) for an example
of how to consume the modules from another flake.

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

Host-specific configuration lives in the consuming repositories, not in this
flake.

## Module Dependencies

**Important**: Most Home-Manager feature modules (`clj-neovim`, `clj-shell`, `clj-git`, etc.) depend on `clj-lib` to provide the `config.lib.clj.linkDotfile` function. You have two options:

1. **Use a preset** (recommended): Presets automatically include `clj-lib` and all necessary dependencies.

   The presets compose in a chain:

   * `clj-preset-minimal`: familiar shell and basic tools for servers and administrative accounts
   * `clj-preset-development`: Minimal plus Neovim's full profile and development tooling
   * `clj-preset-full`: Development plus GUI and personal workstation software

   ```nix
   imports = [dotfiles.modules.homeManager.clj-preset-development];
   ```

   Import only the highest-level preset a host needs. Importing both a preset and one of its dependencies causes duplicate module imports.

2. **Import `clj-lib` explicitly**: When using individual feature modules, you must import `clj-lib` first:

   ```nix
   imports = [
     dotfiles.modules.homeManager.clj-lib
     dotfiles.modules.homeManager.clj-neovim
     dotfiles.modules.homeManager.clj-shell
   ];
   ```

**Why not auto-import?** Due to a [limitation in NixOS/nixpkgs#340361](https://github.com/NixOS/nixpkgs/issues/340361), importing the same flake-based module multiple times causes "option already declared" errors. Having feature modules import `clj-lib` themselves would cause conflicts when using presets.

## Editable Dotfiles

Dotfiles use Nix store copies by default. To edit files directly in a local
checkout, enable editable mode and set the checkout location:

```nix
clj.dotfiles = {
  editable = true;
  repoPath = "${config.home.homeDirectory}/path/to/my/dotfiles";
};
```

`repoPath` must be an absolute string pointing to the repository root. It defaults to
`${config.home.homeDirectory}/Repositories/personal/dotfiles`. Symlinks and shell
startup wrappers both use this location. Moving the checkout requires updating
this option and rebuilding the Home Manager configuration.

## Impermanence

The `clj-impermanence` module provides integration with [nix-community/impermanence](https://github.com/nix-community/impermanence) for systems with ephemeral root filesystems.

Persistent directories are pre-configured based on common needs (SSH, GPG, browser data, development directories, etc.).
