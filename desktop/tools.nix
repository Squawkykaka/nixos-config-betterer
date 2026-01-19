{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.mpv
  ];
}
