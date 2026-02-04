#
# Kanata config for Nix-darwin
#
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    colima
    # Docker CLI client
    docker
  ];
}
