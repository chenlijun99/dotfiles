# Shared NixOS account policy.
{...}: {
  flake.modules.nixos.clj-users = {
    # Keep declarative password hashes authoritative. This also lets oo7's
    # activation warning identify real account-password changes.
    users.mutableUsers = false;
  };
}
