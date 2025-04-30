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
      userContent = ''
        /*
         * Hide Leechblock from addon manager
         * https://www.proginosko.com/leechblock/faq/hide-addon/
         * A desperate attempt to curb procrastination xD.
         */
        [addon-id='leechblockng@proginosko.com'] { display: none !important; }
      '';
      settings = {
        "browser.tabs.closeWindowWithLastTab" = false;
        # Required for userContent
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      # Enforce the search engine configuration configured using home-manager
      # Will lose the existing configuration from Firefox, but I don't care.
      search.force = true;
      search.engines = {
        "bing".metaData.alias = "b";

        "google".metaData.alias = "g";
        "Google scholar" = {
          urls = [
            {
              template = "https://scholar.google.com/scholar?q={searchTerms}";
            }
          ];
          definedAliases = ["gs"];
        };
        "Google Maps" = {
          urls = [
            {
              template = "https://www.google.com/maps/search/{searchTerms}";
            }
          ];
          definedAliases = ["gm"];
        };
        "Google translate" = {
          urls = [
            {
              template = "https://translate.google.com/?sl=auto&tl=en&text={searchTerms}&op=translate";
            }
          ];
          definedAliases = ["gt" "lg"];
        };

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
          icon = "https://nixos.wiki/favicon.png";
          # every day
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["nw"];
        };

        # Language related
        "WordReference" = {
          urls = [{template = "https://www.wordreference.com/enit/{searchTerms}";}];
          icon = "https://www.wordreference.com/favicon.ico";
          # every day
          updateInterval = 24 * 60 * 60 * 1000;
          definedAliases = ["lw"];
        };
      };
    };
  };
}
