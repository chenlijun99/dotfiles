{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      # perf GUI
      hotspot
    ];
  };
}
