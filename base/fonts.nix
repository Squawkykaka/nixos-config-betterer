{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.bqn386
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.fira-code
  ];
}
