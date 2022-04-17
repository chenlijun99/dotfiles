#
# NixOS config for running as a VirtualBox guest
#
{...}: {
  imports = [
    ../../modules/dev.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../users/lijun
    ../../users/lijun-test
    ../../users/test
  ];

  virtualisation.virtualbox.guest.enable = true;

  # Define your hostname.
  networking.hostName = "lijun-virtualbox-guest";

  boot = {
    # The docs says: Whether to enable grow the root partition on boot.
    # Probably to allow the dynamically allocated disk size in VirtualBox
    growPartition = true;
    # See https://nixos.org/manual/nixos/stable/index.html#sec-instaling-virtualbox-guest
    loader.grub.device = "/dev/sda";
    initrd.checkJournalingFS = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  swapDevices = [
    {
      device = "/var/swap";
      size = 2048;
    }
  ];
}
