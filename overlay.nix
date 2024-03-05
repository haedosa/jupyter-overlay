final: prev: {

  # For jupyter
  mkIhaskellKernel = { name ? "Haedosa"
                     , packages ? p : []
                     } : final.callPackage ./kernels/ihaskell {
                           inherit name packages;
                         };

  mkIpythonKernel = { name ? "Haedosa"
                    , python3 ? final.python3
                    , packages ? p : []
                    }: final.callPackage ./kernels/ipython {
                         inherit name packages python3;
                       };

  mkJupyterlab = { haskellKernelName ? "Haedosa"
                 , haskellPackages ? p: []
                 , python3 ? final.python3
                 , pythonKernelName ? "Haedosa"
                 , pythonPackages ? p: [] }: let
                   ihaskellKernel = final.mkIhaskellKernel
                     {
                       name = haskellKernelName;
                       packages = haskellPackages;
                     };
                   ipythonKernel = final.mkIpythonKernel
                     {
                       inherit python3;
                       name = pythonKernelName;
                       packages = pythonPackages;
                     };
    in final.python3Packages.jupyterlab.overridePythonAttrs (oldAttrs: {
      makeWrapperArgs = oldAttrs.makeWrapperArgs ++ [
        "--set JUPYTER_PATH ${ihaskellKernel}:${ipythonKernel}"
      ];
    });

  mypython = final.python3.withPackages (p: [
    p.numpy
    p.scipy
    p.pandas
    p.requests
    p.matplotlib
  ]);

  jupyterlab = final.mkJupyterlab {
      haskellKernelName = "Haedosa";
      haskellPackages = p: with p;
        [ hvega
          # ihaskell-hvega
          # add haskell pacakges if necessary
        ];
      pythonKernelName = "Haedosa";
      pythonPackages = p: with p;
        [ scipy
          numpy
          tensorflow-bin
          matplotlib
          scikit-learn
          pandas
          lightgbm
          pytorch
          # add more python pacakges if necessary
        ];
    };
}
