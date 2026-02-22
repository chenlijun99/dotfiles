{...}: let
  # CLI utils that should be also available as root
  systemPackages = pkgs:
    with pkgs; [
      python313
      curl
      wget
      file
      htop
      tree
      vifm
      fzf
      ripgrep
      # GNU coreutils
      coreutils
      # I need `ts` from this package.
      moreutils
      # Useful for working with JSON on the commandline
      jq
    ];

  # Helper: Create a basic module with enable option for a context
  mkContextModule = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.clj.programs.cli-utils.enable = lib.mkEnableOption "CLI utilities" // {default = true;};

    config = lib.mkIf config.clj.programs.cli-utils.enable {
      environment.systemPackages = systemPackages pkgs;
    };
  };
in {
  flake.modules.nixos.clj-cli-utils = mkContextModule;
  flake.modules.darwin.clj-cli-utils = mkContextModule;

  flake.modules.homeManager.clj-cli-utils = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.clj.programs.cli-utils.enable = lib.mkEnableOption "CLI utilities" // {default = true;};

    config = lib.mkIf config.clj.programs.cli-utils.enable {
      home = {
        packages = with pkgs;
          (systemPackages pkgs)
          ++ [
            tldr
            # Temporarily disable doInstallCheck, which fails due to newest pandoc removing support for a flag
            # See https://discourse.nixos.org/t/ripgrep-all-build-error-on-latest-unstable/31907/3
            (ripgrep-all.overrideAttrs (old: {
              doInstallCheck = false;
            }))
            rclone
            devenv
          ];

        file = {
          ".vifm" = {
            source = config.lib.clj.linkDotfile "src/vifm";
          };
          ".ctags" = {
            source = config.lib.clj.linkDotfile "src/ctags";
          };
          ".detoxrc" = {
            source = config.lib.clj.linkDotfile "src/detoxrc";
          };
          ".gdbinit" = {
            source = config.lib.clj.linkDotfile "src/gdbinit";
          };
          ".ls_colors" = {
            source = config.lib.clj.linkDotfile "src/ls_colors";
          };
          ".markdownlint.jsonc" = {
            source = config.lib.clj.linkDotfile "src/markdownlint.jsonc";
          };
          ".markdownlintrc" = let
            stripJsoncCommentsNaive = inputPath: let
              drv = pkgs.stdenv.mkDerivation {
                name = "jsonc-to-json" + inputPath;
                src = inputPath;
                dontUnpack = true;
                buildInputs = [pkgs.jq];
                buildPhase = ''
                  mkdir -p $out
                  # Use jq to validate and format the JSON
                  sed -E 's/\/\/.*$//' $src | jq > $out/output.json
                '';
              };
            in (drv + "/output.json");
          in {
            source = stripJsoncCommentsNaive ../../../markdownlint.jsonc;
          };
          # GNU readline config
          # Mostly for Vim keybindings
          ".inputrc" = {
            source = config.lib.clj.linkDotfile "src/inputrc";
          };
        };
      };
    };
  };
}
