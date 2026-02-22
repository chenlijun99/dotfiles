{...}: {
  flake.modules.homeManager.clj-tmux = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.clj.programs.tmux.enable = lib.mkEnableOption "Tmux configuration" // {default = true;};

    config = lib.mkIf config.clj.programs.tmux.enable {
      home = {
        packages = with pkgs; [
          tmux
          # For tmux-yank
          xsel
        ];
        file = {
          ".tmux" = {
            source = config.lib.clj.linkDotfile "./src/tmux";
          };
          ".tmux.conf" = {
            source = config.lib.clj.linkDotfile "./src/tmux.conf";
          };
        };
      };
    };
  };
}
