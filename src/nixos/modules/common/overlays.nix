#
# This file centrally handles al the overlays
#
{
  pkgs,
  inputs,
  config,
  ...
} @ args: let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
  };
  pkgs-pcloud-ok = import inputs.nixpkgs-unstable-pcloud-ok {
    system = pkgs.system;
    config = {
      allowUnfree = true;
    };
  };
in {
  nixpkgs.overlays = [
    (final: prev: {
      # My custom Anki
      anki-bin = pkgs.callPackage ./anki {};
      # My custom okular
      okular = import ./okular args;
      # My custom zotero
      zotero = import ./zotero (args // {zotero = prev.zotero;});

      neovim = pkgs-unstable.neovim;
      # Nix formatter
      alejandra = pkgs-unstable.alejandra;
      home-manager = pkgs-unstable.home-manager;
      flameshot = pkgs-unstable.flameshot;
      drawio = pkgs-unstable.drawio;

      pcloud = pkgs-pcloud-ok.pcloud;
      # Cryptomator 1.8 doesn't work.
      # FUSE mount doesn't work.
      cryptomator = pkgs-pcloud-ok.cryptomator;
      # The link's content is updated from time to time as new WeChat versions are released.
      # See https://github.com/nix-community/nur-combined/blob/3a60aba83aac2972253090b0a011464d5d1fb28d/repos/xddxdd/pkgs/default.nix#L167-L174
      #
      # To get the new sha256, run `nix store prefetch-file https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe`
      #
      # This derivation patches Wine, thus Wine needs to be built.
      # wechat = config.nur.repos.xddxdd.wine-wechat.override {
      #   version = "3.9.7";
      #   setupSrc = builtins.fetchurl {
      #     url = "https://dldir1.qq.com/weixin/Windows/WeChatSetup.exe";
      #     sha256 = "sha256-esiCE8KzxfHzjnhzUKc+1UWMF/Fhz6mxuono0H/6GHI=";
      #   };
      # };
      wechat = config.nur.repos.xddxdd.wechat-uos-bin;
    })
  ];
  nixpkgs.config.permittedInsecurePackages = [
    # Neede for config.nur.repos.xddxdd.wechat-uos-bin
    "openssl-1.1.1w"
  ];
}
