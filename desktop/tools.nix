{ pkgs, wrappers, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.vscodium
    pkgs.mpv
    pkgs.ghostty
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
    pkgs.kdePackages.korganizer
  ];
}
