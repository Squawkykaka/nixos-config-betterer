{
  pkgs,
  lib,
  adios,
}: let
  root = {
    name = "root";
    modules = adios.lib.importModules ./.;
  };

  tree = (adios root).eval {
    options = {
      "/nixpkgs" = {
        inherit pkgs lib;
      };
    };
  };
in
  tree.root.modules
