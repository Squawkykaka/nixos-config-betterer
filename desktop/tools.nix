{ pkgs, wrappers, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.mpv
    wrappers.ghostty.drv
  ];
}
