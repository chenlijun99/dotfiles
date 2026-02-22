{...}: {
  # NixOS system-level configuration for perf
  flake.modules.nixos.clj-performance = {
    config,
    lib,
    ...
  }: {
    options.clj.programs.performance = {
      enable = lib.mkEnableOption "Performance profiling tools" // {default = true;};
      gui.enable = lib.mkEnableOption "Performance profiling tools" // {default = true;};
    };

    config = lib.mkIf config.clj.programs.performance.enable {
      # Allow unprivileged perf events (less secure but more convenient)
      boot.kernel.sysctl = {
        "kernel.perf_event_paranoid" = -1;
        "kernel.kptr_restrict" = 0;
      };
    };
  };

  flake.modules.homeManager.clj-performance = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.clj.programs.performance.enable = lib.mkEnableOption "Performance profiling tools" // {default = true;};

    config = lib.mkIf config.clj.programs.performance.enable {
      home.packages =
        # CLI tools (Linux only)
        lib.optionals (!pkgs.stdenv.isDarwin) (
          with pkgs; [
            perf
            flamegraph
            inferno
          ]
        )
        # GUI tools (conditional)
        ++ lib.optionals (config.clj.programs.performance.enable or false) (with pkgs; [
          hotspot
        ]);
    };
  };
}
