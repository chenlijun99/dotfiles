# "lijun-cli" is a user that has everything I need to live in the CLI.
# I used this account for system admin, dev ops work.
{...}: {
  users.users = {
    lijun-cli = {
      isNormalUser = true;
      description = "Lijun Chen CLI";
      extraGroups = ["wheel" "networkmanager" "docker"];
      # Initial empty password
      hashedPassword = "";
    };
  };
  home-manager.users.lijun-cli = import ./home.nix;
}
