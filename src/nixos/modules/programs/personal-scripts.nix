# AusweisApp2 (German ID card application)
{...}: {
  flake.modules.homeManager.clj-personal-scripts = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      ../../../local/bin/scripts.nix
    ];

    home.file = {
      ".local/share/applications/clj_time_to_sleep.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_time_to_sleep.desktop";
      };
      ".local/share/applications/clj_ghostty-vim.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_ghostty-vim.desktop";
      };

      ".local/share/applications/clj_switch_to_dolphin.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_switch_to_dolphin.desktop";
      };
      ".local/share/applications/clj_switch_to_firefox.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_switch_to_firefox.desktop";
      };
      ".local/share/applications/clj_switch_to_ghostty.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_switch_to_ghostty.desktop";
      };
      ".local/share/applications/clj_switch_to_keepassxc.desktop" = {
        source = config.lib.clj.linkDotfile "./src/local/share/applications/clj_switch_to_keepassxc.desktop";
      };
    };
  };
}
