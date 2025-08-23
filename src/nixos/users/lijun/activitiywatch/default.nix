{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    (activitywatch.override {
      extraWatchers = [
        # This is the window watcher that supports KDE Wayland
        (callPackage ./aw-awatcher.nix {})
        (callPackage ./aw-watcher-media-player.nix {})
      ];
    })
  ];
  xdg.configFile = {
    "autostart/aw-qt.desktop" = {
      source = "${pkgs.aw-qt}/share/applications/aw-qt.desktop";
    };
    "awatcher" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/awatcher";
    };
    "activitywatch" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/activitywatch";
    };
  };
}
