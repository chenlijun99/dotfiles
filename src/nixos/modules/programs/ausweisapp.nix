# AusweisApp2 (German ID card application)
{...}: {
  flake.modules.nixos.ausweisapp = {pkgs, ...}: {
    programs.ausweisapp = {
      enable = true;
      openFirewall = true;
    };
  };
}
