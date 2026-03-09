{ types, ... }@adios:
{
  options = {
    settings = {
      default = {
        theme = "gruvbox";
        editor = {
          line-number = "relative";
          soft-wrap.enable = true;
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
        pkgs.erlang-language-platform
      ];
  };
}
