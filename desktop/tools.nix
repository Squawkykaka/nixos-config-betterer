{ self, pkgs, ... }:
{
  programs.thunar.enable = true;
  environment.systemPackages = [
    pkgs.wireshark
    pkgs.nixd
    pkgs.rustup
    pkgs.filezilla
    pkgs.feh
    pkgs.thunderbird
    pkgs.vesktop
    pkgs.vscodium
    pkgs.ghostty
    pkgs.vicinae
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
    pkgs.gajim
    pkgs.swaybg
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.brightnessctl
    self.wrappers.firefox.drv
  ];
}
