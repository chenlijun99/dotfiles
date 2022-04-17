#
# Base packages that all users who operate in a GUI environment can use
#
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    gparted
  ];

  # Input method for chinese
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [libpinyin];
}
