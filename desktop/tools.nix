{ self, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.vesktop
    pkgs.vscodium
    pkgs.mpv
    pkgs.ghostty
    pkgs.vicinae
    pkgs.gimp
    pkgs.imagemagick
    pkgs.ffmpeg-full
    pkgs.kdePackages.korganizer

    (pkgs.callPackage "${self.sources.watt}/nix/package.nix" { })
  ];
}
