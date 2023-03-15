#
# Wrap zotero to launch it in a FHS envrionment.
#
# We need it because Zotero looks for common PDF reader in `/usr/bin/` and
# only if it finds them it handles the `page` query parameter in PDF open
# parameters.
#
{
  config,
  pkgs,
  inputs,
  lib,
  zotero,
  ...
}: (pkgs.buildFHSUserEnv {
  # also determines the name of the wrapped command
  name = zotero.pname;

  passthru = {
    name = zotero.pname;
    version = zotero.version;
  };

  # additional libraries which are commonly needed for extensions
  targetPkgs = pkgs: (with pkgs; [
    # Make okular available in FHS, so that Zotero can find it.
    # This is an essential part of my workflow :
    # PDF link => Zotero => opens correct page using Okular.
    okular
  ]);

  # symlink shared assets, including icons and desktop entries
  extraInstallCommands = ''
    ln -s "${zotero}/share" "$out/"
  '';

  runScript = "${zotero}/bin/${zotero.pname}";
})
