{
  rustPlatform,
  lib,
  xdotool,
  makeDesktopItem,
  copyDesktopItems,
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

  nativeBuildInputs = [ copyDesktopItems ];

  desktopItems = [
    (makeDesktopItem {
      name = "org.nuisance.xwayland-global-shortcut-bridge";
      desktopName = "XWayland Global Shortcut Bridge";
      exec = "xwayland-global-shortcut-bridge";
    })
  ];
})
