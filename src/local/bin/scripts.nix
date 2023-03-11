# This home-manager module contains my utility scripts
{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = let
      clj_script = script_name: extra_attrs:
        pkgs.writeShellApplication ({
            name = script_name;
            text = builtins.readFile (./. + "/${script_name}.sh");
          }
          // extra_attrs);
      clj_alacritty = clj_script "clj_alacritty" {
        runtimeInputs = with pkgs; [alacritty];
      };
      clj_multiscreenshot = clj_script "clj_multiscreenshot" {
        runtimeInputs = with pkgs; [
          libnotify
          flameshot
          xdotool
          xorg.xinput
          wl-clipboard-x11
          wl-clipboard
          imagemagick
        ];
      };
      clj_reset_kde_desktop = clj_script "clj_reset_kde_desktop" {
        runtimeInputs = with pkgs; [alacritty];
      };
      clj_time_to_sleep = clj_script "clj_time_to_sleep" {
        runtimeInputs = with pkgs; [qrencode];
      };
      clj_switch_theme =
        clj_script "clj_switch_theme" {};
      clj_de_autostart =
        clj_script "clj_de_autostart" {};
    in [
      clj_alacritty
      clj_multiscreenshot
      clj_reset_kde_desktop
      clj_time_to_sleep
      clj_switch_theme
      clj_de_autostart
    ];
  };
}
