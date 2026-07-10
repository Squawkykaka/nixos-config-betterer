{
  pkgs,
  sources,
}:
let
  adios = import "${sources.adios}/adios";
  adios-wrappers = import sources.adios-wrappers { inherit adios; };

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
builtins.mapAttrs (
  _: wrapper:
  if wrapper.args.options ? __functor then
    (removeAttrs wrapper.args.options [ "__functor" ]) // { drv = wrapper { }; }
  else
    wrapper.args.options
) tree.modules
