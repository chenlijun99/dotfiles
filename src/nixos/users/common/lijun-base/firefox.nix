{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
    # Why do we use firefox-bin? See ../../../modules/base-gui.nix
    package = pkgs.firefox-bin;
    profiles.lijun = {
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
      };
      search.engines = {
        "Google".metaData.alias = "g";
        "Bing".metaData.alias = "b";

        # NixOS related
        "Nix Packages" = {
          urls = [
            {
              template = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = ["np"];
        };
        "NixOS options" = {
          urls = [
            {
              template = "https://search.nixos.org/options?query={searchTerms}";
            }
          ];
          definedAliases = ["no"];
        };
        "NixOS Wiki" = {
          urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
          iconUpdateURL = "https://nixos.wiki/favicon.png";
          # every day
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["nw"];
        };

        # Language related
        "WordReference" = {
          urls = [{template = "https://www.wordreference.com/enit/{searchTerms}";}];
          iconUpdateURL = "https://www.wordreference.com/favicon.ico";
          # every day
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["lw"];
        };
        "Google translate" = {
          urls = [
            {
              template = "https://translate.google.com/?sl=auto&tl=en&text={searchTerms}&op=translate";
            }
          ];
          definedAliases = ["lg"];
        };
      };
    };
  };
}
