{pkgs, ...}: let
  ghostty = pkgs.ghostty;
in {
  programs.ghostty = {
    enable = true;
    package = ghostty;
    enableZshIntegration = true;
    settings = {
      background-opacity = 0.6;
      background-blur = true;
      # theme = "ayu";
      # custom-shader = ["~/shaders/bettercrt.glsl" "~/shaders/bloom.glsl"];
    };
  };
}
