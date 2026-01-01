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
          xclip
          wl-clipboard-x11
          wl-clipboard
          imagemagick
        ];
      };
      clj_reset_kde_desktop = clj_script "clj_reset_kde_desktop" {
        runtimeInputs = with pkgs; [alacritty kdePackages.kdbusaddons kdePackages.kde-cli-tools];
      };
      clj_time_to_sleep = clj_script "clj_time_to_sleep" {
        runtimeInputs = with pkgs; [qrencode];
      };
      clj_switch_theme =
        clj_script "clj_switch_theme" {};
      clj_de_autostart =
        clj_script "clj_de_autostart" {};
      # See [Basic flake: run existing (python, bash) script](https://discourse.nixos.org/t/basic-flake-run-existing-python-bash-script/19886/2)
      clj_stay_focused = pkgs.writeScriptBin "clj_stay_focused" ''
        export PATH=${pkgs.lib.makeBinPath [pkgs.wmctrl pkgs.libnotify]}:$PATH
        ${./clj_stay_focused.py}
      '';

      # Why go through this instead of wrapping the python script in a bash
      # script? Apparently doing so makes the python script startup much
      # slwoer (400-500ms), which becoems noticeable for the
      # use case of this script.
      clj_win_cycle_or_launch = pkgs.python3Packages.buildPythonApplication rec {
        pname = "clj_win_cycle_or_launch";
        version = "0.1.0";
        pyproject = false;
        dontUnpack = true;
        propagatedBuildInputs = with pkgs; [
          kdotool
        ];

        # This sets up a virtual environment and installs the dependencies.
        installPhase = ''
          install -Dm755 "${./clj_win_cycle_or_launch.py}" "$out/bin/${pname}"
        '';
        doCheck = false;

        meta = with pkgs.lib; {
          description = "A simple Python application";
          license = licenses.mit;
          maintainers = with maintainers; [];
        };
      };
      clj_setup_project = pkgs.writeScriptBin "clj_setup_project" ''
        ${./clj_setup_project.py}
      '';
    in [
      clj_alacritty
      clj_multiscreenshot
      clj_reset_kde_desktop
      clj_time_to_sleep
      clj_switch_theme
      clj_de_autostart
      clj_stay_focused
      clj_win_cycle_or_launch
      clj_setup_project
    ];
  };
}
