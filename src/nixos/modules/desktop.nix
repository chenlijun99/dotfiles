{ ... }:
{
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5 = {
      enable = true;
    };
    libinput.enable = true; # for touchpad support on many laptops
  };

  # Enable sound in virtualbox appliances.
  hardware.pulseaudio.enable = true;
}
