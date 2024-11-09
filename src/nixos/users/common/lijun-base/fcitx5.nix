{
  config,
  pkgs,
  inputs,
  ...
} @ args: let
  utils = import ../utils.nix args;
in {
  xdg.configFile = {
    "fcitx5_config" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/config";
      target = "fcitx5/config";
    };
    "fcitx5_profile" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/profile";
      target = "fcitx5/profile";
    };
    "fcitx5_addon_classicui" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/conf/classicui.conf";
      target = "fcitx5/conf/classicui.conf";
    };
    "fcitx5_addon_pinyin" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/conf/pinyin.conf";
      target = "fcitx5/conf/pinyin.conf";
    };
    "fcitx5_addon_cloudpinyin" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/conf/cloudpinyin.conf";
      target = "fcitx5/conf/cloudpinyin.conf";
    };
    "fcitx5_addon_chttrans" = {
      source = utils.mkOutOfStoreRelativeThisRepoSymLink "./src/config/fcitx5/conf/chttrans.conf";
      target = "fcitx5/conf/chttrans.conf";
    };
  };
}
