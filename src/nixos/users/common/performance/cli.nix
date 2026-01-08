{
  pkgs,
  lib,
  ...
}: {
  home = lib.mkIf (!pkgs.stdenv.isDarwin) {
    packages = with pkgs; [
      # Performance profiler
      perf
      # Scripts from Brendan Gregg
      flamegraph
      inferno
    ];
  };
}
