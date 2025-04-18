{
  pkgs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    btop
    bitwarden-desktop
    vscodium
    vesktop
    pavucontrol
    ripgrep
    xfce.thunar

    prismlauncher
    r2modman
    floorp

    # cli
    unzip
    zip
    killall
    tree
    wl-clipboard
    wtype
    brightnessctl
    hyprpicker
    grimblast
    showmethekey
    nil

    # WM stuff
    libsForQt5.xwaylandvideobridge
    libnotify
    # hyprpolkitagent
  ];
}
