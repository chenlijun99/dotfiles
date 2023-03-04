# "test" is a fresh user, with none of my customizations
{...}: {
  users.users = {
    test = {
      isNormalUser = true;
      description = "Test account";
      extraGroups = ["networkmanager"];
      # Initial empty password
      hashedPassword = "";
    };
  };
}
