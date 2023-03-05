{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.flameshot = {
    enable = true;
    settings = {

    };
  };
}
