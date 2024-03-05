{
  description = "jupyter-overlay";

  inputs = {

    haedosa.url = "github:haedosa/flakes";
    nixpkgs.follows = "haedosa/nixpkgs-23-11";
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
          config = {
            allowUnfree = true;
          };
          overlays = [ self.overlay ];
        };

      in
      {

        packages.default = pkgs.jupyterlab;
        apps.default = {
          type = "app";
          program = "${pkgs.jupyterlab}/bin/jupyter-lab";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.mypython
            pkgs.jupyterlab
          ];
        };
      }
    );

}
