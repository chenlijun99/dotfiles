{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # Performance profiler
      linuxPackages.perf
      # Scripts from Brendan Gregg
      flamegraph
      inferno
    ];
  };
}
