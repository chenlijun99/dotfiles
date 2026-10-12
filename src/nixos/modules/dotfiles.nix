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
      dotfiles.repoPath = lib.mkOption {
        type = lib.types.addCheck lib.types.str (lib.hasPrefix "/");
        default = "${config.home.homeDirectory}/Repositories/personal/dotfiles";
        defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/Repositories/personal/dotfiles"'';
        example = "/home/lijun.chen/Repositories/work/lijun-sonar-dev/external/dotfiles";
        description = ''
          Absolute path to the dotfiles checkout used in editable mode.
          Use a string rather than a Nix path literal so the checkout stays
          outside the Nix store. This is the repository root containing src/,
          not the src/nixos flake directory.
        '';
      };
    };

    config = let
      repoPath = config.clj.dotfiles.repoPath;
      editableMode = config.clj.dotfiles.editable or false;
    in {

      # Helper function: returns store path or out-of-store symlink based on mode
      lib.clj.linkDotfile = relativePath:
        if editableMode
        then config.lib.file.mkOutOfStoreSymlink (repoPath + "/" + relativePath)
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
            if [ -d ${lib.escapeShellArg repoPath} ]; then
              # shellcheck source=/dev/null
              source ${lib.escapeShellArg (repoPath + "/" + relativePath)}
            else
              cat >&2 <<'DOTFILES_WARNING_EOF'
            WARNING: Dotfiles repository not found at ${repoPath}
            Editable dotfiles symlinks will be broken until the checkout exists.
            Set clj.dotfiles.repoPath to your existing checkout, or clone it:
              git clone --recursive https://github.com/chenlijun99/dotfiles ${lib.escapeShellArg repoPath}
            DOTFILES_WARNING_EOF
            fi
          '';
        }
        else {source = ../../.. + ("/" + relativePath);};
    };
  };
}
