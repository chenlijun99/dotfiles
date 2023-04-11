# This module contains every GUI tool that I may use for networking
# applications
{
  config,
  pkgs,
  inputs,
  ...
} @ args: {
  home = {
    packages = with pkgs; [
      wireshark
    ];
  };
}
