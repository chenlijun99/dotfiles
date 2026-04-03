# This module provides dotfiles management functionality and common options
#
# IMPORTANT: This module must be imported when using feature modules that need
# dotfiles linking (clj-neovim, clj-shell, clj-git, clj-cli-utils, clj-ghostty).
#
# Either:
#   1. Use a preset (clj-preset-minimal, clj-preset-full) which includes this
#   2. Import this module explicitly along with feature modules
#
# Why not auto-import? Due to nixpkgs#340361, flake-based modules cannot be
# imported multiple times. Feature modules can't import clj-lib themselves
# because that would conflict when using presets that also import clj-lib.
{...}: {
  # Home-Manager module - provides common clj.* options and dotfiles helpers
  flake.modules.homeManager.clj-lib = {
    lib,
    config,
    ...
  }: {
    options.clj = {
      dotfiles.editable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          When true, dotfiles are symlinked to the repository for quick iteration.
          When false, dotfiles are stored in the Nix store (default, more reliable).
        '';
      };
    };

    config = let
      THIS_REPO_PATH = "${config.home.homeDirectory}/Repositories/personal/dotfiles";
      editableMode = config.clj.dotfiles.editable or false;
    in {

      # Helper function: returns store path or out-of-store symlink based on mode
      lib.clj.linkDotfile = relativePath:
        if editableMode
        then config.lib.file.mkOutOfStoreSymlink (THIS_REPO_PATH + "/" + relativePath)
        else ../../.. + ("/" + relativePath); # Store path relative to flake root

      # Helper for shell entry-point files (e.g. .bashrc, .zshrc).
      # In editable mode, writes a HM-managed wrapper that sources the real file
      # if the repo exists, otherwise shows a warning. This avoids the chicken-and-egg
      # problem where a broken symlink prevents the warning from ever being shown.
      # Returns a home.file attribute set ({ source = ...; } or { text = ...; }).
      lib.clj.shellInitDotfile = relativePath:
        if editableMode
        then {
          text = ''
            # Managed by Home Manager (editable dotfiles mode).
            # Sources from the dotfiles repository when present; warns otherwise.
            if [ -d "${THIS_REPO_PATH}" ]; then
              # shellcheck source=/dev/null
              source "${THIS_REPO_PATH}/${relativePath}"
            else
              cat >&2 <<'DOTFILES_WARNING_EOF'
            ╔════════════════════════════════════════════════════════════════════╗
            ║ ⚠️  DOTFILES REPOSITORY NOT FOUND                                  ║
            ║                                                                    ║
            ║ Your dotfiles are configured in editable mode, but the repository ║
            ║ has not been cloned yet. Many configuration files are broken      ║
            ║ symlinks until you clone the repository.                          ║
            ║                                                                    ║
            ║ To fix this, run:                                                 ║
            ║   git clone --recursive https://github.com/chenlijun99/dotfiles \ ║
            ║     ~/Repositories/personal/dotfiles                              ║
            ║                                                                    ║
            ║ This warning will disappear once the repository exists.           ║
            ╚════════════════════════════════════════════════════════════════════╝
            DOTFILES_WARNING_EOF
            fi
          '';
        }
        else {source = ../../.. + ("/" + relativePath);};
    };
  };
}
