{ self, pkgs, ... }:
{
  environment.systemPackages = [
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
    (pkgs.callPackage "${self.sources.watt}/nix/package.nix" { })
  ];
}
