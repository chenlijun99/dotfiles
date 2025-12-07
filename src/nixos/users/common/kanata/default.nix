{
  config,
  pkgs,
  lib,
  ...
}:
# Optional file. Include as needed.
# This Nix file sets up the kanata keyboard remapper as a systemd user service
# using home-manager, based on the standard configuration practices.
# It is meant for when you must use a different Linux distro than NixOS.
# NOTE: You need to do some manual steps to set up your user and group and
# udev permission appopriately.
# Check out https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md
{
  # 1. Install the kanata package
  home.packages = [pkgs.kanata];

  # 2. Configure the systemd user service
  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md";
    };
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${pkgs.concatText "kanata-normal-config" [../../../../kanata/normal.kbd ../../../../kanata/common.kbd]}";
      Restart = "on-failure";
    };
    Install = {WantedBy = ["default.target"];};
  };
}
