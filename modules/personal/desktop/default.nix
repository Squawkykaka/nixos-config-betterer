{
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.kaka.desktop.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland desktop";

    terminal = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ghostty;
    };

    fileManager = lib.mkOption {
      type = lib.types.package;
      default = pkgs.xfce.thunar;
    };

    browser = lib.mkOption {
      type = lib.types.package;
      default = inputs.zen-browser.packages.${pkgs.system}.default;
    };
  };

  # Do NOT mkIf here on import, just import submodules
  imports = lib.custom.scanPaths ./.;
}
