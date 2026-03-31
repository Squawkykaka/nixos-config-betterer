{
  pkgs,
  sources,
}:
let
  adios = import "${sources.adios}/adios";
  adios-wrappers = import sources.adios-wrappers { adios = sources.adios; };

  watt = (pkgs.callPackage "${sources.watt}/nix/package.nix" { });
  root.modules = pkgs.lib.recursiveUpdate adios-wrappers (adios.lib.importModules ./.);

  tree = adios root {
    options = {
      "/nixpkgs" = {
        inherit pkgs watt;
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
