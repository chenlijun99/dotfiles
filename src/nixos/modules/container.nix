# Container configuration (Podman + Distrobox)
{...}: {
  flake.modules.nixos.clj-container = {
    pkgs,
    config,
    ...
  }: {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    environment.systemPackages = with pkgs; [
      distrobox
      xhost
      jq
      bindfs
    ];
    environment.persistence.${config.clj.impermanence.persistDir} = {
      directories = [
        "/var/lib/containers"
      ];
    };
  };

  flake.modules.darwin.clj-container = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # microvm
      lima
      # Use colima as docker runtime on macOS insteaf of Docker Desktop
      colima
      # Docker CLI client
      docker
    ];
  };

  flake.modules.homeManager.clj-container = {config, ...}: {
    home.persistence.${config.clj.impermanence.persistDir} = {
      directories = [
        ".local/share/containers"
      ];
    };
  };
}
