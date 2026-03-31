{ types, ... }:
{
  inputs = {
    mkWrapper.path = "/mkWrapper";
    nixpkgs.path = "/nixpkgs";
  };
  options = {
    settings = {
      type = types.attrs;
      description = ''
        Settings to be injected into wrapped package's `watt.toml`.

        See the watt docs for valid options:
        https://github.com/NotAShelf/watt

        Disjoint with the `configFile` option.
      '';
    };
    configFile = {
      type = types.pathLike;
      description = ''
        `watt.toml` file to be injected into the wrapped packages.

        See the watt docs for valid options:
        https://github.com/NotAShelf/watt

        Disjoint with the `settings` option.
      '';
      default = toString ./watt.toml;
    };
    package = {
      type = types.derivation;
      description = "The watt package to be wrapped.";
      defaultFunc = { inputs }: inputs.nixpkgs.watt;
    };
  };

  impl =
    { options, inputs }:
    assert !(options ? configFile && options ? settings);
    let
      inherit (inputs.nixpkgs.pkgs) formats;
      generator = formats.toml { } options.settings;
    in
    inputs.mkWrapper {
      inherit (options) package;
      preSymlink = ''
        mkdir -p $out/watt
      '';
      symlinks = {
        "$out/watt/watt.toml" =
          if options ? configFile then
            options.configFile
          else if options ? settings then
            generator.generate "watt.toml" options.settings
          else
            null;
      };
      environment = {
        WATT_CONFIG = "$out/watt/watt.toml";
      };
    };
}
