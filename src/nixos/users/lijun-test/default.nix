{...}: {
  users.users = {
    lijun-test = {
      isNormalUser = true;
      description = "Lijun Chen Test";
      extraGroups = ["networkmanager"];
      # No password for this user
      hashedPassword = "";
    };
  };
  home-manager.users.lijun-test = import ./home.nix;
}
