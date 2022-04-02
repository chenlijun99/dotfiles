{...}: {
  users.users = {
    test = {
      isNormalUser = true;
      description = "Test account";
      extraGroups = ["networkmanager"];
      # No password for this user
      hashedPassword = "";
    };
  };
}
