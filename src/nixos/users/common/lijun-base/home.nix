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
  imports = [
    ../lijun-cli-base/home.nix
    ../this.nix
    ./firefox.nix
    ./alacritty.nix
    ./flameshot.nix
    ./autostart.nix
    ./desktop.nix
    ./fcitx5.nix
    ../networking/gui.nix
    ../vim/gui.nix
    ../performance/gui.nix
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
      kdePackages.filelight

      # Latex
      texlive.combined.scheme-full
      # Needed for minted
      python310Packages.pygments

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
      # Misc
      pdftk
      inkscape
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
    "baloofilerc" = {
      # Disable KDE baloo file indexing
      # See https://community.kde.org/Baloo/Configuration
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/baloofilerc";
    };
    "strawberry" = {
      # Mainly for two purposes
      #
      # * Remember setting to fingerprint collection
      # * Remember file naming pattern.
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/strawberry";
    };
    "safeeyes" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/safeeyes";
    };
    "zathura" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/config/zathura";
    };
  };
  home.file = {
    ".XCompose" = {
      source = config.lib.clj.mkOutOfStoreRelativeThisRepoSymLink "./src/XCompose";
    };
  };
}
