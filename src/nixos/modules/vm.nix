#
# System-wide configuration related to virtual machine hypervisors
#
# Sources:
#
# * https://github.com/TechsupportOnHold/Nixos-VM/tree/main
#   * Main source of this module
# * https://nixos.wiki/wiki/Virt-manager
# * https://github.com/virtio-win/kvm-guest-drivers-windows/wiki/Virtiofs:-Shared-file-system
#   * Share file system with Windows guest using Virtiofs
#   * https://discourse.nixos.org/t/virt-manager-cannot-find-virtiofsd/26752 to solve Virt-manager cannot find virtiofsd
# * https://wiki.archlinux.org/title/QEMU
#   * As always, Arch wiki never disappoints
#
{
  config,
  pkgs,
  ...
}: {
  # Enable dconf (System Management Tool)
  programs.dconf.enable = true;

  # Install necessary packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
    # Required for virtiofs-based shared filesystem
    virtiofsd
  ];

  # Manage the virtualisation services
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
