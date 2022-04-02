#
# System-wide configuration related to desktop environment
#
{pkgs, ...}: {
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
    };
    libinput.enable = true; # for touchpad support on many laptops
  };

  environment.systemPackages = with pkgs; [
    latte-dock
    vim
    latte-dock
  ];
}
