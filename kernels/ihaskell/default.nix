{ writeScriptBin
, haskellPackages
, stdenv
, ihaskell ? haskellPackages.ihaskell
, customIHaskell ? null
, extraIHaskellFlags ? ""
, name ? "nixpkgs"
, packages ? (_:[])
, pkgs
}:

let

  ghcEnv = haskellPackages.ghcWithPackages (self: [ihaskell] ++ packages self);

  ihaskellSh = writeScriptBin "ihaskell" ''
    #! ${stdenv.shell}
    export GHC_PACKAGE_PATH="$(echo ${ghcEnv}/lib/*/package.conf.d| tr ' ' ':'):$GHC_PACKAGE_PATH"
    export PATH="${pkgs.lib.makeBinPath ([ ghcEnv ])}:$PATH"
    ${ihaskell}/bin/ihaskell ${extraIHaskellFlags} -l $(${ghcEnv}/bin/ghc --print-libdir) "$@"'';

  kernelFile = {
    display_name = "Haskell - " + name;
    language = "haskell";
    argv = [
      "${ihaskellSh}/bin/ihaskell"
      "kernel"
      "{connection_file}"
      "+RTS"
      "-M3g"
      "-N2"
      "-RTS"
    ];
    logo64 = "logo-64x64.svg";
  };

in stdenv.mkDerivation {
    name = "ihaskell-kernel";
    phases = "installPhase";
    src = ./haskell.svg;
    buildInputs = [ ghcEnv ];
    installPhase = ''
      mkdir -p $out/kernels/ihaskell_${name}
      cp $src $out/kernels/ihaskell_${name}/logo-64x64.svg
      echo '${builtins.toJSON kernelFile}' > $out/kernels/ihaskell_${name}/kernel.json
    '';
  }
