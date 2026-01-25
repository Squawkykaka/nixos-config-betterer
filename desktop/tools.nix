{ pkgs, wrappers, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.mpv
    wrappers.ghostty.drv
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
  ];
}
