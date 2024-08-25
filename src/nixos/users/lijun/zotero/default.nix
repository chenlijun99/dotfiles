{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./zotero.nix
  ];
  programs.zotero = {
    enable = true;
    profiles.lijun = {
      settings = {
        # Use System PDF reader to open PDF
        "extensions.zotero.fileHandler.pdf" = "system";

        "extensions.zotmoov.attach_search_dir" = "${config.home.homeDirectory}/Downloads";
        "extensions.zotmoov.dst_dir" = "${config.home.homeDirectory}/pCloudDrive/Zotero";
        "extensions.zotmoov.enable_attach_dir" = true;

        # This setting from Zotero will be used also by zotmoov when moving files to the destination directory.
        "extensions.zotero.attachmentRenameTemplate" = "{{ firstCreator suffix=\" - \" }}{{ year suffix=\" - \" }}{{ title truncate=\"80\" }}";

        "extensions.zotero.translators.better-bibtex.citekeyFormat" = "auth.lower+shorttitle(3,3)+year";
        "extensions.zotero.translators.better-bibtex.citekeyFormatEditing" = "auth.lower+shorttitle(3,3)+year";

        ########################################################################
        # Below are the ZotFile settings. I don't use ZotFile anymore.
        # Anyway, I guess it's not harmful to keep them around.
        ########################################################################
        # Don't copy files into Zotero. Rather, create links to dest_dir.
        "extensions.zotfile.import" = false;
        # Where to move the attachments
        "extensions.zotfile.dest_dir" = "${config.home.homeDirectory}/pCloudDrive/Zotero";
        # Where to find new attachments
        "extensions.zotfile.source_dir" = "${config.home.homeDirectory}/Downloads";
        "extensions.zotfile.tablet.dest_dir" = "${config.home.homeDirectory}/pCloudDrive/Zotero/Tablet";
        # Set Quick copy to "Better Bibtex"
        "extensions.zotero.export.quickCopy.setting" = "export=ca65189f-8815-4afe-8c8b-8c7c15f0edca";
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
      };
    };
  };
}
