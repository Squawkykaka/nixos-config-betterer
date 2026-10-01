{ promise, ... }: {
  options = {
    settings = {
      default = {
        theme = "ayu_dark";
        editor = {
          line-number = "relative";
          soft-wrap.enable = true;
          mouse = false;
        };
      };
    };
    extraPackages.default = promise (
      { inputs }:

      let
        inherit (inputs.nixpkgs) pkgs;
      in
      [
        pkgs.superhtml
        pkgs.nixd
        pkgs.erlang-language-platform
      ]
    );
  };
}
