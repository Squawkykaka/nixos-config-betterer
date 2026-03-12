{ types, ... }:
{
  name = "mangowc";

  inputs = {
    mkWrapper.path = "/mkWrapper";
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    package = {
      type = types.derivation;
      description = "The mangowc package to be wrapped.";
      defaultFunc = { inputs }: inputs.nixpkgs.pkgs.mangowc;
    };

    settings = {
      type = types.attrs;
      description = ''
        Settings to be injected into the wrapped package's `config.conf`.

        See the mangowc docs for valid options:
        https://mangowc.vercel.app/docs/configuration/basics

        Disjoint with the `configFile` option.
      '';
    };

    configFile = {
      type = types.pathLike;
      description = ''
        `config.conf` file to be injected into the wrapped package.

        See the mangowc docs for valid options:
        https://mangowc.vercel.app/docs/configuration/basics

        Disjoint with the `settings` option.
      '';
      default = toString "/home/gleask/nixos/wrappers/mangowc/config.conf";
    };
  };

  impl =
    { options, inputs }:
    assert !(options ? configFile && options ? settings);
    let
      inherit (inputs.nixpkgs.pkgs) writeText;
      inherit (inputs.nixpkgs.lib) generators;
      generated = generators.toKeyValue { } options.settings;
    in
    inputs.mkWrapper {
      inherit (options) package;
      name = "mango";
      preSymlink = ''
        mkdir -p $out/mango
      '';

      symlinks = {
        "$out/mango/config.conf" =
          if options ? configFile then
            options.configFile
          else if options ? settings then
            writeText "config.conf" generated
          else
            null;
      };

      environment = {
        XDG_CONFIG_HOME = "$out";
      };
    };
}
