# "lijun" is the user that I normally use, for everything.
{...}: {
  users.users = {
    lijun = {
      isNormalUser = true;
      description = "Lijun Chen";
      extraGroups = ["wheel" "networkmanager" "docker" "dialout" "libvirtd" "wireshark"];
      # Initial password.
      # Change it immediately on the first login!
      hashedPassword = "$6$SUUT8ZWKpI$3/0xAo2JFFOmtBPxSwGGzKdMgD5slbPaZgHWd9l53SELl8ohaMAVDeIiY6E15LXG0Lmqc1wDKSFjM7f/cMArQ.";
    };
  };
  home-manager.users.lijun = import ./home.nix;
}
