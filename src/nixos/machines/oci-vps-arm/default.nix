{...}: {
  imports = [
    ../../modules/dev.nix
    ../../modules/docker.nix
    ../../modules/ssh-server.nix
    ../../users/lijun-cli
    ../../users/test
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = false;
  networking.hostName = "nixos-main";
  networking.domain = "subnet04082253.vcn04082253.oraclevcn.com";
}
