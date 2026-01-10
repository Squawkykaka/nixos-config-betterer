{ adios }:
let
  inherit (adios) types;
in
{
  name = "helix";

  inputs.nixpkgs.path = "/nixpkgs";

  options = {
    settings = {
      type = types.attrs;
      default = { };
    };
  };

  impl =
    { options, inputs }:
    let
      inherit (inputs.nixpkgs) pkgs lib;
      inherit (pkgs) symlinkJoin makeWrapper linkFarm;

      helixConfig = pkgs.writers.writeTOML "config.toml" options.settings;
    in
    symlinkJoin {
      name = "helix-wrapped";
      paths = [
        pkgs.helix
      ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hx \
          --add-flags "--config ${helixConfig}"
      '';
      meta.mainProgram = "hx";
    };
}
