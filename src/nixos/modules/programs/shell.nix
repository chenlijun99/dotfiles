# Shell configuration (Zsh, Bash, Starship, direnv)
{...}: let
  # Shared system-level config for NixOS and Darwin
  systemConfigModule = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.clj.programs.shell.enable = lib.mkEnableOption "Shell configuration" // {default = true;};

    config = lib.mkIf config.clj.programs.shell.enable {
      programs.zsh.enable = true;

      # Set zsh as default shell for all users
      users.users = lib.mkDefault (
        lib.mapAttrs (_: userConfig: {
          shell = lib.mkDefault pkgs.zsh;
        })
        config.users.users
      );
    };
  };
in {
  flake.modules.nixos.clj-shell = {
    imports = [
      systemConfigModule
      ({pkgs, ...}: {
        programs.zsh.enable = true;
        users.defaultUserShell = pkgs.zsh;
      })
    ];
  };
  flake.modules.darwin.clj-shell = {
    imports = [
      systemConfigModule
      ({
        config,
        lib,
        ...
      }: {
        programs.zsh = lib.mkIf config.clj.programs.shell.enable {
          enable = true;
          # Improve zsh startup time.
          # See https://github.com/nix-community/home-manager/issues/108
          # Anyway, keep system-wide zsh config minimal. Any advanced customization
          # shuold be done at the system leve.
          enableCompletion = false;
          enableBashCompletion = false;
          enableGlobalCompInit = false;
          enableAutosuggestions = false;
        };
      })
    ];
  };

  flake.modules.homeManager.clj-shell = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.clj.programs.shell.enable = lib.mkEnableOption "Shell configuration (Zsh, Bash, Starship)" // {default = true;};

    config = lib.mkIf config.clj.programs.shell.enable {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      home = {
        packages = with pkgs; [
          zsh
          bashInteractive
          starship
        ];

        file = {
          ".profile" = config.lib.clj.shellInitDotfile "src/profile";
          ".shell_aliases" = {
            source = config.lib.clj.linkDotfile "src/shell_aliases";
          };
          ".shell_env" = {
            source = config.lib.clj.linkDotfile "src/shell_env";
          };
          # Zsh
          ".zprofile" = config.lib.clj.shellInitDotfile "src/zprofile";
          ".zshrc" = config.lib.clj.shellInitDotfile "src/zshrc";
          ".zimrc" = {
            source = config.lib.clj.linkDotfile "src/zimrc";
          };
          ".p10k.zsh" = {
            source = config.lib.clj.linkDotfile "src/p10k.zsh";
          };
          # Bash
          ".bashrc" = config.lib.clj.shellInitDotfile "src/bashrc";
        };
      };
    };
  };
}
