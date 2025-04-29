{ pkgs, ... }:
{
  imports = [
    # Packages with custom configs go here

    ./hyprland

    ########## Utilities ##########
    ./services/swaync.nix # Notification daemon
    ./waybar # infobar
    ./wofi # app launcher
    #./fonts.nix
    #./playerctl.nix # cli util and lib for controlling media players that implement MPRIS
    #./gtk.nix # mainly in gnome
    #./qt.nix # mainly in kde
  ];
  home.packages = [
    pkgs.pavucontrol # gui for pulseaudio server and volume controls
    pkgs.wl-clipboard # wayland copy and paste
    pkgs.brightnessctl # brightness changer
    pkgs.hyprpicker # screenshot tool
    pkgs.grimblast # screenshot tool
    pkgs.wtype # wayland input tool
  ];
}
