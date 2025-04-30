{
  lib,
  config,
  ...
}:
let
  enabled = config.stylix.enable;
in
lib.mkIf enabled {
  stylix = {
    targets = {
      neovim.enable = false;
      waybar.enable = false;
      wofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      firefox.enable = false;
      bat.enable = false;
    };
  };
}
