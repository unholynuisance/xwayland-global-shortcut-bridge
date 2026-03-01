{
  rustPlatform,
  lib,
  xdotool,
}:
let
  c = lib.importTOML ./Cargo.toml;
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = c.package.name;
  version = c.package.version;

  src = ./.;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  buildInputs = [ xdotool ];
})
