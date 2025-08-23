# Taken from https://github.com/NixOS/nixpkgs/pull/406459
# Not yet merged at the time of writing.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aw-watcher-media-player";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "2e3s";
    repo = "aw-watcher-media-player";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6lVW2hd1nrPEV3uRJbG4ySWDVuFUi/JSZ1HYJFz0KdQ=";
  };

  cargoHash = "sha256-1HAoWrJUSQFhG0KbKR8ZEOykMWWtHxUj2OtvXlPhe4k=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    openssl
  ];

  postInstall = ''
    cp -r $src/visualization $out/visualization
  '';

  meta = {
    description = "Watcher of system's currently playing media for ActivityWatch";
    homepage = "https://github.com/2e3s/aw-watcher-media-player";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [XBagon];
    mainProgram = "aw-watcher-media-player";
  };
})
