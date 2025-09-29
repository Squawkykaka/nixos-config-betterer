{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.kaka.desktop;
in {
  options = {
    kaka.desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to enable my custom desktop, this includes hyprland and the tools associated with it.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hm.imports = [
      ./hyprland
      ./wofi
      ./waybar.nix
      ./services/swaync.nix
    ];

    hm.home.packages = [
      pkgs.pavucontrol # gui for pulseaudio server and volume controls
      pkgs.wl-clipboard # wayland copy and paste
      pkgs.brightnessctl # brightness changer
      pkgs.hyprpicker # screenshot tool
      pkgs.wtype # wayland input tool
      pkgs.xfce.thunar # file manager TODO move into own module.
    ];
  };
}
