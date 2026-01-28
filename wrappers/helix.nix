{ types, ... }@adios:
{
  options = {
    settings = {
      default = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          mouse = false;
        };
      };
    };
    extraPackages.defaultFunc =
      { inputs }:
      let
        inherit (inputs.nixpkgs) pkgs;
      in
      [
        pkgs.superhtml
      ];
  };
}
