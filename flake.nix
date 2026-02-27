{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          devenv.shells.default = {
            packages = [
              config.treefmt.build.wrapper
            ]
            ++ lib.attrValues config.treefmt.build.programs;

            languages = {
              rust = {
                enable = true;
              };

              nix = {
                enable = true;
                lsp.package = pkgs.nixd;
              };
            };
          };

          treefmt.programs = {
            rustfmt.enable = true;
            nixfmt.enable = true;
          };
        };
    };
}
