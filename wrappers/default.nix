{
  pkgs,
  sources,
}:
let
  adios = import sources.adios;
  # adios-wrappers = import sources.adios-wrappers { inherit adios; };
  adios-wrappers = import /home/gleask/documents/projects/public/adios-wrappers { inherit adios; };

  root.modules = pkgs.lib.recursiveUpdate adios-wrappers (
    adios.lib.importModules { directory = ./.; }
  );

  tree = adios root {
    options = {
      "/nixpkgs" = {
        inherit pkgs;
      };
    };
  };
in
builtins.mapAttrs (_: wrapper: wrapper // { drv = wrapper { }; }) tree.modules
