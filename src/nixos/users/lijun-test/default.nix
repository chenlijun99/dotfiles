# "lijun-test" is a user that has the same development environment to which I
# am used, but not all the other stuff (note taking, messaging, etc.).
# Use cases:
# * I'm presenting something, I don't want to leak any personal info during 
# the preseentation (chat notifications, emails, browser bookmarks, browser 
# history, etc.)
{...}: {
  users.users = {
    lijun-test = {
      isNormalUser = true;
      description = "Lijun Chen Test";
      extraGroups = ["wheel" "networkmanager" "docker" "dialout" "libvirtd" "wireshark"];
      # Initial empty password
      hashedPassword = "";
    };
  };
  home-manager.users.lijun-test = import ./home.nix;
}
