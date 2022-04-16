# "lijun-test" is a user that has the same development environment to which I
# am used, but not all the other stuff (note taking, messaing, etc.).
{...}: {
  users.users = {
    lijun-test = {
      isNormalUser = true;
      description = "Lijun Chen Test";
      extraGroups = ["wheel" "networkmanager"];
      # No password for this user
      hashedPassword = "";
    };
  };
  home-manager.users.lijun-test = import ./home.nix;
}
