{
  description = "jupyter-overlay";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }@inputs:
    {
      overlay = nixpkgs.lib.composeManyExtensions [ (import ./overlay.nix) ];
    }  // flake-utils.lib.eachDefaultSystem (system:

      let
        pkgs = import nixpkgs {
          inherit system;
          config = {};
          overlays = [ self.overlay ];
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
