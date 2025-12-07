# "lijun-gui" is similar to "lijun", but without personal stuff and KDE stuff
{...}: {
  users.users = {
    lijun = {
      isNormalUser = true;
      description = "Lijun Chen";
      extraGroups = ["wheel" "networkmanager" "docker"];
      # Initial empty password
      hashedPassword = "";
    };
  };
  home-manager.users.lijun = import ./home.nix;
}
