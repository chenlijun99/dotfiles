{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ../common/lijun-base/home.nix
    ../common/kde-config/default.nix
    ./zotero.nix
  ];
  nixpkgs.config.allowUnfree = true;
  programs.zotero = {
    enable = true;
    profiles.lijun = {
      settings = {
        # Use System PDF reader to open PDF
        "extensions.zotero.fileHandler.pdf" = "system";
        # Don't copy files into Zotero. Rather, create links to dest_dir.
        "extensions.zotfile.import" = false;
        # Where to move the attachments
        "extensions.zotfile.dest_dir" = "${config.home.homeDirectory}/pCloudDrive/Zotero";
        # Where to find new attachments
        "extensions.zotfile.source_dir" = "${config.home.homeDirectory}/Downloads";
        "extensions.zotfile.tablet.dest_dir" = "${config.home.homeDirectory}/pCloudDrive/Zotero/Tablet";

        # ZotFile renaming rules
        # Most (maybe all?) of them are default settings. You can easily find
        # them in the ZotFile repository.
        "extensions.zotfile.useZoteroToRename" = false;
        "extensions.zotfile.renameFormat" = "{%a_}{%y_}{%t}";
        "extensions.zotfile.renameFormat_patent" = "{%a_}{%y_}{%t}";
        "extensions.zotfile.truncate_title" = true;
        "extensions.zotfile.truncate_smart" = true;
        "extensions.zotfile.truncate_title_max" = true;
        "extensions.zotfile.max_titlelength" = 80;
        "extensions.zotfile.truncate_authors" = true;
        "extensions.zotfile.max_authors" = 2;
        "extensions.zotfile.number_truncate_authors" = 1;
        "extensions.zotfile.add_etal" = true;
        "extensions.zotfile.etal" = " et al";
        "extensions.zotfile.authors_delimiter" = "_";
        "extensions.zotfile.removeDiacritics" = false;
        "extensions.zotfile.removePeriods" = false;

        "extensions.zotero.translators.better-bibtex.citekeyFormat" = "auth.lower+shorttitle(3,3)+year";
        "extensions.zotero.translators.better-bibtex.citekeyFormatEditing" = "auth.lower+shorttitle(3,3)+year";
      };
    };
  };
  home = {
    username = "lijun";
    homeDirectory = "/home/lijun";
    packages = with pkgs; [
      # Cloud drive
      pcloud
      nextcloud-client
      cryptomator

      # Anki
      anki-bin

      # Note taking app
      obsidian

      (libsForQt5.okular.overrideAttrs (oldAttrs: rec {
        patches = (lib.optionals (oldAttrs ? patches) oldAttrs.patches) ++ [./okular.patch];
      }))

      # Email client
      thunderbird

      # A second browser is always useful
      chromium

      # Password manager
      keepassxc

      # Communication
      slack
      teams
      zoom-us
      tdesktop

      # Multimedia
      strawberry
    ];
  };
}
