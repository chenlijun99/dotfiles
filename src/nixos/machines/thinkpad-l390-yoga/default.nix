#
# NixOS config for running on my ThinkPad-L390-Yoga
#
{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base-gui.nix
    ../../modules/dev.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/bluetooth.nix
    ../../modules/docker.nix
    ../../modules/virtualbox.nix
    ../../modules/printing.nix
    ../../modules/vm.nix
    ../../modules/tlp.nix
    ../../users/lijun
    ../../users/lijun-test
    ../../users/test
  ];

  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    #
    # TODO: consider whether to switch to grub
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Define your hostname.
  networking.hostName = "lijun-ThinkPad-L390-Yoga";
  # Enables wireless support via network manager.
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
