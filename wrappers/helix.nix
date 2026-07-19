_: {
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
    extraPackages.defaultFunc =
      { inputs }:
      let
        inherit (inputs.nixpkgs) pkgs;
      in
      [
        pkgs.superhtml
        pkgs.nil
        pkgs.nixd
        pkgs.erlang-language-platform
      ];
  };
}
