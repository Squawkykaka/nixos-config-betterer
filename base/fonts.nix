{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
