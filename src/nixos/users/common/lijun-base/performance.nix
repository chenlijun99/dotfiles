{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      # Performance profiler
      linuxPackages.perf
      # perf GUI
      hotspot
      # Scripts from Brendan Gregg
      flamegraph
      inferno
    ];
  };
}
