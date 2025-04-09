{ pkgs, pkgs-unstable, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = 
    (with pkgs; [
      btop
      bitwarden-desktop
      vscodium
      obsidian
      vesktop
      pavucontrol
      ripgrep

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
    ])

    ++

    (with pkgs-unstable; [
      gale
    ]);
}
