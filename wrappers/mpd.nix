{ types, ... }@adios:
{
  name = "mpd";

  inputs = {
    mkWrapper = "/mkWrapper";
    nixpkgs = "/nixpkgs";
  };

  options = {
    settings = {
      type = types.attrs;
      mutatorType = types.attrs;
      mergeFunc = adios.lib.mergeFuncs.concatLines;
    };

    package = {
      type = types.derivation;
      defaultFunc = { inputs }: inputs.nixpkgs.pkgs.mpd;
    };
  };

  impl =
    { options, inputs }:
    let

    in
    inputs.mkWrapper {
      package = options.package;

    };
}
