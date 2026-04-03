# Container configuration (Podman + Distrobox)
{...}: {
  flake.modules.homeManager.clj-ai = {pkgs, ...}: {
    home.packages = with pkgs; [
      github-copilot-cli
    ];
  };
}
