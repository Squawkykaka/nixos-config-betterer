{ pkgs, wrappers, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.mpv
    pkgs.ghostty
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
  ];
}
