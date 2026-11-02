# The nixpkgs voxtype package ships the OSD launcher but no frontend binary.
# Pin the official signed release binary instead of building the Rust frontend
# and a duplicate GTK stack from the upstream flake.
{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  wrapGAppsHook4,
  cairo,
  glib,
  gtk4,
  gtk4-layer-shell,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "voxtype-osd-gtk4";
  version = "1.1.1";

  src = fetchurl {
    url = "https://github.com/peteonrails/voxtype/releases/download/v${finalAttrs.version}/voxtype-${finalAttrs.version}-linux-x86_64-osd-gtk4";
    hash = "sha256-4W+W3PBGuc+olVQbrLcwU3CPPt76jSRaK0I7KIzVoPA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook4
  ];

  buildInputs = [
    cairo
    glib
    gtk4
    gtk4-layer-shell
    stdenv.cc.cc.lib
  ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/voxtype-osd-gtk4"
  '';

  meta = {
    description = "GTK4 on-screen display frontend for Voxtype";
    homepage = "https://voxtype.io";
    license = lib.licenses.mit;
    mainProgram = "voxtype-osd-gtk4";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
})
