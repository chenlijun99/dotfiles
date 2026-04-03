{...}: {
  flake.modules.homeManager.clj-input-method = {
    pkgs,
    lib,
    config,
    ...
  }: let
    isLinux = pkgs.stdenv.isLinux;
  in
    lib.mkIf isLinux {
      i18n.inputMethod = {
        type = "fcitx5";
        enable = true;
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            kdePackages.fcitx5-qt
            kdePackages.fcitx5-chinese-addons
            rime-data
            fcitx5-rime
            rime-ice
          ];
        };
      };
      xdg.configFile = {
        "fcitx5_config" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/config";
          target = "fcitx5/config";
        };
        "fcitx5_profile" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/profile";
          target = "fcitx5/profile";
        };
        "fcitx5_addon_classicui" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/conf/classicui.conf";
          target = "fcitx5/conf/classicui.conf";
        };
        "fcitx5_addon_pinyin" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/conf/pinyin.conf";
          target = "fcitx5/conf/pinyin.conf";
        };
        "fcitx5_addon_cloudpinyin" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/conf/cloudpinyin.conf";
          target = "fcitx5/conf/cloudpinyin.conf";
        };
        "fcitx5_addon_chttrans" = {
          source = config.lib.clj.linkDotfile "src/config/fcitx5/conf/chttrans.conf";
          target = "fcitx5/conf/chttrans.conf";
        };
      };
      home.activation = {
        # fcitx5 often overwrites our system links...
        # And then upon re-activation home-manager compains that the files
        # already exist and fails.
        #
        # See some (mildly) related discussion
        # https://github.com/nix-community/home-manager/issues/3090
        # Specificaly https://github.com/nix-community/home-manager/issues/3090#issuecomment-1835357162
        fcitx5Configs = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/config
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/profile
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/conf/classicui.conf
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/conf/pinyin.conf
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/conf/cloudpinyin.conf
          $DRY_RUN_CMD rm -f ~/.config/fcitx5/conf/chttrans.conf
        '';
      };
    };
}
