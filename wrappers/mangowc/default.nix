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
      default = toString ./config.conf;
    };

    autostart = {
      type = types.string;
      description = ''
        Script that get runs on startup, injected into the wrapped packages `autostart.sh`

        The format is a regular bash script.

        Disjoint with the `autostartFile` option.
      '';
    };

    autostartFile = {
      type = types.pathLike;
      default = toString ./autostart.sh;
      description = ''
        `autostart.sh` file to be injected into the wrapped package.

        The format is a regular bash script.

        Disjoint with the `autostart` option.
      '';
    };
  };

  impl =
    { options, inputs }:
    assert !(options ? configFile && options ? settings);
    assert !(options ? autostart && options ? autostartFile);
    let
      inherit (inputs.nixpkgs.pkgs) writeText;
      inherit (inputs.nixpkgs.lib) generators;
      generated = generators.toKeyValue { } options.settings;

      config-conf =
        if options ? configFile then
          options.configFile
        else if options ? settings then
          writeText "config.conf" generated
        else
          null;
      autostart-sh =
        if options ? autostartFile then
          options.autostartFile
        else if options ? autostart then
          writeText "autostart.sh" options.autostart
        else
          null;
    in
    inputs.mkWrapper {
      inherit (options) package;
      name = "mango";
      preSymlink = ''
        mkdir -p $out/mango
      '';

      symlinks = {
        "$out/mango/config.conf" = config-conf;
        "$out/mango/autostart.sh" = autostart-sh;
      };

      flags = [
        "-c"
        "$out/mango/config.conf"
        "-s"
        "$out/mango/autostart.sh"
      ];
    };
}
