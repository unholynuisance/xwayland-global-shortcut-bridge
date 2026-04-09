{
  self,
  ...
}:

{
  config.perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = {
        xwayland-global-shortcut-bridge = pkgs.callPackage "${self}/package.nix" { };
      };
    };

}
