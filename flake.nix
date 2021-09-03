{
  description = "jupyter-overlay";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/master";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs =
    inputs@{ self, nixpkgs, flake-compat, flake-utils, ... }:
    {
      overlays = [ (import ./overlay.nix) ];
      overlay = nixpkgs.lib.composeManyExtensions self.overlays;
    }  // flake-utils.lib.eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          config = {};
          overlays = self.overlays;
        };

      in
      {

        defaultPackage = pkgs.jupyterlab;
        defaultApp = {
          type = "app";
          program = "${pkgs.jupyterlab}/bin/jupyter-lab";
        };

      }
    );

}
