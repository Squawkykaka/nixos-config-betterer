{ self, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.noctalia-shell
    pkgs.joplin
    pkgs.joplin-desktop
    pkgs.thunderbird
    pkgs.vesktop
    pkgs.vscodium
    pkgs.ghostty
    pkgs.vicinae
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
    pkgs.gajim
    pkgs.kdePackages.korganizer

    pkgs.swaybg
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
    pkgs.brightnessctl
    self.wrappers.firefox.drv

    pkgs.krita
    self.wrappers.watt.drv
  ];
}
