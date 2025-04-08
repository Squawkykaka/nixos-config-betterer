{ lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # theme = "ayu";
      # custom-shader = ["~/shaders/bettercrt.glsl" "~/shaders/bloom.glsl"];
    };
  };
}