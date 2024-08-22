#
# Graphic tablet
#
{pkgs, ...}: {
  services.xserver = {
    wacom.enable = true;
    modules = with pkgs; [
      xf86_input_wacom
    ];
  };
  environment.systemPackages = with pkgs; [
    libwacom
  ];
}
