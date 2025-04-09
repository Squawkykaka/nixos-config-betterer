{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    btop
    bitwarden-desktop
    vscodium
    obsidian
    vesktop
    pavucontrol
    ripgrep
    # gale.overrideAttrs (old: rec {
    #   finalAttrs.version = "1.5.6";
    # })

#    logseq
    dolphin
    prismlauncher

    # cli
    unzip
    zip
    killall
    tree
    wl-clipboard
    wtype
    brightnessctl
    hyprpicker
    showmethekey

    # WM stuff
    libsForQt5.xwaylandvideobridge
    libnotify
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];
}
