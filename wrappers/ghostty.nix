{ adios }:
let
  inherit (adios) types;
in
{
  name = "ghostty";

  inputs = {
    mkWrapper.path = "/mkWrapper";
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    config = {
      type = types.attrs;
      description = ''
        Config to be injected into the wrapped package's `config`.

        See the ghostty documentation for valid options:
        https://ghostty.org/docs/config/reference

        Disjoint with the `configFile` option.
      '';
      default = {
        background-opacity = 0.6;
        background-blur = true;
      };
    };
    configFile = {
      type = types.pathLike;
      description = ''
        `config` file to be injected into the wrapped package.

        See the nushell documentation on file syntax:
        https://ghostty.org/docs/config/reference

        Disjoint with the `config` option.
      '';
    };
  };

  impl =
    { inputs, options }:
    let
      inherit (inputs.nixpkgs.lib) generators;
      inherit (inputs.nixpkgs.pkgs) ghostty formats;

      generator = formats.keyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = generators.mkKeyValueDefault { } " = ";
      };
    in
    assert !(options ? config && options ? configFile);
    inputs.mkWrapper {
      name = "ghostty";
      package = ghostty;
      preWrap = ''
        mkdir -p $out/ghostty/themes
      '';
      symlinks = {
        "$out/ghostty/config" =
          if options ? configFile then
            options.configFile
          else if options ? config then
            generator.generate "ghostty-config" options.config
          else
            null;
      };
      flags =
        if options ? configFile then
          [ "--config-file=${options.configFile}" ]
        else if options ? config then
          [ "--config-file=${generator.generate "ghostty-config" options.config}" ]
        else
          [ ];
    };
}
