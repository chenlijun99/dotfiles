{...}: {
  flake.modules.homeManager.clj-git = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.clj.programs.git.enable = lib.mkEnableOption "Git configuration" // {default = true;};

    config = lib.mkIf config.clj.programs.git.enable {
      home = {
        packages = with pkgs; [
          git
          git-lfs
        ];
        file = {
          ".gitconfig" = {
            source = config.lib.clj.linkDotfile "src/gitconfig";
          };
        };
      };
    };
  };
}
