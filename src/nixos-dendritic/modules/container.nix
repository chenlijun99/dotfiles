# Container configuration (Podman + Distrobox)
{...}: {
  flake.modules.nixos.clj-container = {pkgs, ...}: {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment.systemPackages = with pkgs; [
      distrobox
      xhost
      jq
      bindfs
    ];
  };

  flake.modules.darwin.clj-container = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Use colima as docker runtime on macOS insteaf of Docker Desktop
      colima
      # Docker CLI client
      docker
    ];
  };
}
