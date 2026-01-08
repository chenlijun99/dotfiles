# This module contains every CLI tool that I may use for networking
# applications
{
  pkgs,
  lib,
  ...
}: {
  # Some of these packages are unavailable for darwin.
  home = lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [
      # For `dig`
      bind.dnsutils
      # To my interest, includes "ping", "traceroute"
      traceroute
      netcat-openbsd
      nmap
    ];
  };
}
