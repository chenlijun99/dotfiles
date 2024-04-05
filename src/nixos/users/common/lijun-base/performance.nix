{
  config,
  pkgs,
  inputs,
  ...
}: {
  home = {
    packages = with pkgs; [
      # Performance profiler
      pkgs.linuxPackages.perf
      # perf GUI
      pkgs.hotspot
    ];
  };
}
