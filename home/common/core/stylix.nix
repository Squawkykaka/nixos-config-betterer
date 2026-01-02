{pkgs, ...}: {
  stylix = {
    enable = true;
    targets = {
      neovim.enable = false;
      waybar.enable = false;
      wofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      firefox.enable = false;
      bat.enable = false;
      vscode.enable = false;
      kde.enable = false;
      qt.enable = false;
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  };
}
