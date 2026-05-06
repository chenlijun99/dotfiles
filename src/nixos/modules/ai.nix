# Container configuration (Podman + Distrobox)
{...}: {
  flake.modules.homeManager.clj-ai = {lib, config, pkgs, ...}: {
    options.clj.ai.enable = lib.mkEnableOption "AI setup" // {default = true;};
    config = lib.mkIf config.clj.ai.enable {
      home.packages = with pkgs; [
        github-copilot-cli
      ];
    };
  };
}
