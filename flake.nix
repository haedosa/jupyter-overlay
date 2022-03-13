{
  description = "jupyter-overlay";

  inputs = {

    haedosa.url = "github:haedosa/flakes";
    nixpkgs.follows = "haedosa/nixpkgs";
    flake-utils.follows = "haedosa/flake-utils";

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
