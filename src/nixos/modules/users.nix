{...}: {
  users.users = {
    lijun = {
      isNormalUser = true;
      description = "Lijun's user account";
      extraGroups = ["wheel" "networkmanager"];
      hashedPassword = "$6$SUUT8ZWKpI$3/0xAo2JFFOmtBPxSwGGzKdMgD5slbPaZgHWd9l53SELl8ohaMAVDeIiY6E15LXG0Lmqc1wDKSFjM7f/cMArQ.";
    };
  };

  services.xserver.displayManager = {
    autoLogin = {
      enable = true;
      user = "lijun";
    };
    sddm.autoLogin.relogin = true;
  };
}
