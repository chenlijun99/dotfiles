{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # Performance profiler
      perf
      # Scripts from Brendan Gregg
      flamegraph
      inferno
    ];
  };
}
