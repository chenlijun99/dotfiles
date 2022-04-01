{ ... }:
{
  users.users.demo =
    { isNormalUser = true;
      description = "My default user account";
      extraGroups = [ "wheel" ];
      password = "demo";
      uid = 1000;
    };

  services.xserver.displayManager = {
    autoLogin = {
      enable = true;
      user = "demo";
    };
    sddm.autoLogin.relogin = true;
  };
}
