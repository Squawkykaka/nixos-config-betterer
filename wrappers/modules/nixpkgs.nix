{ adios }:
{
  name = "nixpkgs";

  options = {
    pkgs = {
      # No default value - the value is injected in the eval stage
      type = adios.types.attrs;
    };
    lib = {
      type = adios.types.attrs;
    };
  };
}
