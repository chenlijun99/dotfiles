# This module contains every CLI tool that I may use for networking
# applications
{
  config,
  pkgs,
  inputs,
  ...
} @ args: {
  home = {
    packages = with pkgs; [
      # For `dig`
      bind.dnsutils
      # To my interest, includes "ping", "traceroute"
      traceroute
    ];
  };
}
