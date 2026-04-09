{
  inputs,
  ...
}:
{
  imports = [
    inputs.devenv.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  config.perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config.devenv.shells.default = {
        packages = config.treefmt.build.devShell.nativeBuildInputs ++ [
          pkgs.xdotool
        ];

        languages = {
          rust = {
            enable = true;
          };

          nix = {
            enable = true;
            lsp.package = pkgs.nixd;
          };
        };

        containers = lib.mkForce { };
      };

      config.treefmt.programs = {
        rustfmt.enable = true;
        nixfmt.enable = true;
      };
    };
}
