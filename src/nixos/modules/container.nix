#
# System-wide configuration related to Docker
#
{pkgs, ...}: {
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  environment.systemPackages = with pkgs; [
    # distrobox create --image archlinux:latest --name archlinux --home /var/lib/containers/distrobox/home/archlinux --volume /etc/static/profiles/per-user:/etc/profiles/per-user:ro --verbose
    distrobox

    # 2024-03-21 TODO: 
    # After I switched from Docker to Podman and after I've discovered distrobox,
    # are these still needed?
    # Not the most secure option, but `xhost` is useful to remove X11 authorization.
    # I sometimes use this to mmake GUI from docker container work.
    xorg.xhost
    # These two are sometimes used to make docker container filesystem accessible to the host
    jq
    bindfs
  ];
}
