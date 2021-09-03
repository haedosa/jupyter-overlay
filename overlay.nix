final: prev: with final; {

  # For jupyter
  mkIhaskellKernel = { name ? "Haedosa"
                     , packages ? p : []
                     } : callPackage ./kernels/ihaskell {
                           inherit name packages;
                         };

  mkIpythonKernel = { name ? "Haedosa"
                    , packages ? p : []
                    }: callPackage ./kernels/ipython {
                         inherit name packages;
                       };

  mkJupyterlab = { haskellKernelName ? "Haedosa"
                 , haskellPackages ? p: []
                 , pythonKernelName ? "Haedosa"
                 , pythonPackages ? p: [] }: let
                   ihaskellKernel = mkIhaskellKernel { name = haskellKernelName;
                                                       packages = haskellPackages; };
                   ipythonKernel = mkIpythonKernel { name = pythonKernelName;
                                                     packages = pythonPackages; };
    in python3Packages.jupyterlab.overridePythonAttrs (oldAttrs: {
      makeWrapperArgs = oldAttrs.makeWrapperArgs ++ [
        "--set JUPYTER_PATH ${ihaskellKernel}:${ipythonKernel}"
      ];
    });

  jupyterlab = mkJupyterlab {
      haskellKernelName = "Haedosa";
      haskellPackages = p: with p;
        [ hvega
          ihaskell-hvega
          # add haskell pacakges if necessary
        ];
      pythonKernelName = "Haedosa";
      pythonPackages = p: with p;
        [ # add python pacakges if necessary
          scipy
          numpy
        ];
    };
}
