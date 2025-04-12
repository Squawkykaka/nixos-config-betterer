{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gcc
    jetbrains.idea-ultimate
    jdk17
    gradle
    sbctl
    vlc
    nixfmt-rfc-style

    (lutris.override {
      extraPkgs = pkgs: [
        wineWowPackages.stable
        gamescope
        geckodriver
      ];
    })
  ];
}
