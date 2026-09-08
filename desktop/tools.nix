{ self, pkgs, ... }:
{
  programs.thunar.enable = true;
  environment.systemPackages = [
    pkgs.godot
    pkgs.rustup
    pkgs.thunderbird
    pkgs.ghostty
    pkgs.vicinae
    pkgs.gimp
    pkgs.imagemagick
    pkgs.wl-clipboard
    pkgs.brightnessctl
    self.wrappers.firefox.drv
  ];
}
