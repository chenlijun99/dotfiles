{ pkgs, self, nixpkgs, nixpkgs-unstable, ... }:

let
  unstable-pkgs = import nixpkgs-unstable {
    overlays = [
      (self: super: {
        neovim = super.neovim.override {
          viAlias = true;
          vimAlias = true;
        };
      })
    ];
  };
in
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    # From the docs:
    # This option specifies the Nix package instance to use throughout the system.
    #
    # So with this we control which version of nix (the package manager) we want to use
    #
    # pkgs.nixFlakes is an alias of a version of nix that supports flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
    experimental-features = nix-command flakes
    '';
    # Pinning Nixpkgs. See https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    registry.nixpkgs.flake = nixpkgs;
  };
  # Let demo build as a trusted user.
  # nix.trustedUsers = [ "demo" ];

  # Mount a VirtualBox shared folder.
  # This is configurable in the VirtualBox menu at
  # Machine / Settings / Shared Folders.
  # fileSystems."/mnt" = {
  #   fsType = "vboxsf";
  #   device = "nameofdevicetomount";
  #   options = [ "rw" ];
  # };

  # By default, the NixOS VirtualBox demo image includes SDDM and Plasma.
  # If you prefer another desktop manager or display manager, you may want
  # to disable the default.
  # services.xserver.desktopManager.plasma5.enable = lib.mkForce false;
  # services.xserver.displayManager.sddm.enable = lib.mkForce false;

  # Enable GDM/GNOME by uncommenting above two lines and two lines below.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # \$ nix search wget
  environment.systemPackages = with pkgs; [
    wget git git-lfs tmux fzf
    gcc
    latte-dock
    # To support neovim clipboard
    xclip
    # For tmux-yank
    xsel
    # Ripgrep. I use it in Vim and also on CLI
    ripgrep ripgrep-all
    # My terminal of choice
    alacritty
    # Email client
    thunderbird
    # Main browser
    firefox
    # A second browser is always useful
    chromium
    # Citation manager
    zotero
    # Note taking app
    obsidian
    # I never use it, but it may be useful
    vscode
  ] ++ [
    # Get most recent release of Neovim from unstable-pkgs
    unstable-pkgs.neovim
  ];
  environment.variables.EDITOR = "nvim";

  # Install fonts
  fonts.fonts = with pkgs; [
    # My Alacritty config uses NerdFont patched Hack
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
}
