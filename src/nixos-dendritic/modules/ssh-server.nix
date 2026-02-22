# SSH server configuration
{
  flake.modules.nixos.clj-ssh-server = {lib, ...}: {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      extraConfig = ''
        # Allow
        # * publickey authentication
        # * keyboard-interactive authentication for 2fa
        AuthenticationMethods publickey,keyboard-interactive
      '';
    };
    security.pam.services = {
      sshd = {
        googleAuthenticator.enable = true;
        # Required to make googleAuthenticator work.
        # See https://github.com/NixOS/nixpkgs/issues/115044#issuecomment-791909238
        unixAuth = lib.mkForce true;
      };
    };
  };
}
