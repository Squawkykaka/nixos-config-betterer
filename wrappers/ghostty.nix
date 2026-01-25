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
    themes = {
      type = types.attrsOf types.attrs;
    };
    themesDir = {
      type = types.pathLike;
    };
  };

  impl =
    { inputs, options }:
    let
      inherit (inputs.nixpkgs.lib) generators;
      inherit (inputs.nixpkgs.pkgs) ghostty formats;
      inherit (builtins) listToAttrs attrNames;

      generator = formats.keyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = generators.mkKeyValueDefault { } " = ";
      };
      generatedThemes =
        if options ? themesDir then
          {
            "$out/helix/themes" = options.themesDir;
          }
        else if options ? themes then
          listToAttrs (
            map (name: {
              name = "$out/ghostty/themes/${name}.toml";
              value = generator.generate name options.themes.${name};
            }) (attrNames options.themes)
          )
        else
          { };
    in
    assert !(options ? config && options ? configFile);
    assert !(options ? themes && options ? themesDir);
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
      }
      // generatedThemes;
    };
  environment = {
    XDG_CONFIG_HOME = "$out";
  };
}
