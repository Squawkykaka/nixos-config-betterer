{ adios }:
let
  inherit (adios) types;
in
{
  name = "nushell";

  inputs.nixpkgs.path = "/nixpkgs";

  options = {
    settings = {
      mutators = [ "/zoxide" ];
      type = types.str;
      mutatorType = types.str;
      mergeFunc =
        { mutators, options }:
        let
          inherit (builtins) attrValues concatStringsSep;
        in
        concatStringsSep "\n" (attrValues mutators);
      # default = "";
    };
  };

  impl =
    { inputs, options }:
    let
      inherit (inputs.nixpkgs) pkgs;
      inherit (pkgs) makeWrapper symlinkJoin writeText;
    in
    symlinkJoin {
      name = "nushell-wrapped";
      paths = [
        pkgs.nushell
      ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/nu \
          --add-flags "--config ${writeText "config.nu" options.settings}"
      '';
      meta.mainProgram = "nu";
    };
}
