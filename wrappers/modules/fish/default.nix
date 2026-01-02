{adios}: {
  name = "fish";

  inputs = {
    nixpkgs.path = "/nixpkgs";
  };

  options = {
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs) pkgs;
    inherit (pkgs) symlinkJoin;
  in
    symlinkJoin {
      name = "fish-wrapped";
      paths = [pkgs.fish];
      postBuild = ''
        rm -r $out/share/fish/vendor_completions.d $out/share/fish/vendor_functions.d
        ln -s ${./config.fish} $out/share/fish/vendor_conf.d/config.fish
        ln -s ${./functions} $out/share/fish/vendor_functions.d
        ln -s ${./completions} $out/share/fish/vendor_completions.d
      '';
      meta.mainProgram = "fish";
    };
}
