{ pkgs, ... }:
let
  ghostty = pkgs.ghostty.overrideAttrs (_: {
    preBuild = ''
      shopt -s globstar
      sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
      shopt -u globstar
    '';
  });
in
{
  programs.ghostty = {
    enable = true;
    package = ghostty;
    enableZshIntegration = true;
    settings = {
      # theme = "ayu";
      # custom-shader = ["~/shaders/bettercrt.glsl" "~/shaders/bloom.glsl"];
    };
  };
}
