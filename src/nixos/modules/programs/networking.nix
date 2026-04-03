{...}: {
  flake.modules.homeManager.clj-networking = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options.clj.programs.networking = {
      enable = lib.mkEnableOption "Networking tools" // {default = true;};
      gui.enable = lib.mkEnableOption "GUI networking tools (Wireshark)" // {default = true;};
    };

    config = lib.mkIf config.clj.programs.networking.enable {
      home.packages =
        lib.optionals (!pkgs.stdenv.isDarwin) (
          with pkgs; [
            bind.dnsutils
            traceroute
            netcat-openbsd
            nmap
          ]
        )
        ++ lib.optionals config.clj.programs.networking.gui.enable (with pkgs; [
          wireshark
        ]);
    };
  };
}
