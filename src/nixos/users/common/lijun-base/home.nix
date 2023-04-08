# "lijun-base" contains everything that I normally use to work, excluding
# stuff such as note taking, messaging, etc.
{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  imports = [
    ../lijun-cli-base/home.nix
    ../this.nix
    ./firefox.nix
    ./alacritty.nix
    ./flameshot.nix
    ./autostart.nix
    ./desktop.nix
  ];
  home = {
    # See https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
    stateVersion = "21.11";
    packages = with pkgs; [
      # I never use it, but it may be useful
      vscode
      # Lightweight PDF reader
      zathura
      # For offline documentation
      zeal
      # Disk usage statistics
      libsForQt5.filelight
      # Latex
      texlive.combined.scheme-medium
      plantuml
      graphviz
      doxygen
      drawio
      pandoc
      libreoffice
      xournalpp
      vlc
      # Protect my eyes
      safeeyes

      # terminal emulators that I use to interface with serial port
      picocom
      gtkterm

      # Count lines of code
      scc
    ];
  };
  # Enable management of XDG base directories using home-manager
  xdg.enable = true;
  xdg.configFile = {
    "ibus" = {
      /*
      NOTE: don't let home-manager handle the whole `config/ibus` folder,
      since it would cause the `config/ibus` folder to be read-only.
      The `config/ibus` folder also contains stateful data that the ibus-daemon
      needs to write.
      */
      source = ../../../../config/ibus/rime/default.custom.yaml;
      target = "ibus/rime/default.custom.yaml";
    };
    "safeeyes" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/safeeyes";
    };
    "zathura" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/zathura";
    };
  };
}
