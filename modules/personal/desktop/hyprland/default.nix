{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.kaka.desktop.hyprland.enable {
    hm.home.packages = [
      pkgs.pavucontrol # gui for pulseaudio server and volume controls
      pkgs.wl-clipboard # wayland copy and paste
      pkgs.brightnessctl # brightness changer
      pkgs.hyprpicker # screenshot tool
      pkgs.wtype # wayland input tool
      pkgs.xfce.thunar # file manager TODO move into own module.
    ];

    hm.imports = [
      ./hyprland
      ./wofi
      ./waybar.nix
      ./services/swaync.nix
    ];
  };
}
