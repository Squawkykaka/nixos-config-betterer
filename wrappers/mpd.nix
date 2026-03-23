{ types, ... }@adios:
{
  inputs = {
    mkWrapper = "/mkWrapper";
    nixpkgs = "/nixpkgs";
  };

  options = {
    settings = {
      type = types.string;
    };
    configFile = {
      type = types.pathLike;
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
      preSymlink = ''
        mkdir -p $out/mpd
      '';
    };
}
