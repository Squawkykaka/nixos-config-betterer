{ self, pkgs, ... }:
let
  rom = (pkgs.callPackage "${self.sources.rom}/nix/package.nix" { });
in
{
  environment.systemPackages = [
    pkgs.joplin
    pkgs.joplin-desktop
    pkgs.thunderbird
    pkgs.vesktop
    pkgs.vscodium
    pkgs.mpv
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
    rom
  ];
}
