#
# System-wide configuration related to Docker
#
{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    # For unknown reasons, OMNET++ IDE in my Docker container doesn't work 
    # when using Docker 24.0.5.
    package = pkgs.docker_20_10;
  };
  environment.systemPackages = with pkgs; [
    # Not the most secure option, but `xhost` is useful to remove X11 authorization.
    # I sometimes use this to mmake GUI from docker container work.
    xorg.xhost

    # These two are sometimes used to make docker container filesystem accessible to the host
    jq
    bindfs
  ];
}
