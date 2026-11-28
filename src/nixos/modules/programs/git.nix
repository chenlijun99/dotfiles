{ ... }: {
  flake.modules.homeManager.clj-git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.clj.programs.git.enable = lib.mkEnableOption "Git configuration" // {
        default = true;
      };

      config = lib.mkIf config.clj.programs.git.enable {
        home = {
          packages = with pkgs; [
            git
            git-lfs
            gh
          ];
          file = {
            ".gitconfig" = {
              source = config.lib.clj.linkDotfile "src/gitconfig";
            };
          };
          # The keyring persists tokens, but gh still needs hosts.yml to know
          # which hosts and accounts those tokens belong to.
          persistence.${config.clj.impermanence.persistDir}.directories = [
            {
              directory = ".config/gh";
              mode = "0700";
            }
          ];
        };
      };
    };
}
