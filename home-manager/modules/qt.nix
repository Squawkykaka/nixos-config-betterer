{ pkgs, ... }:
{
  home.packages = with pkgs; [
    papirus-icon-theme
    pcmanfm-qt
  ];
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      package = pkgs.kdePackages.qt6gtk2;
      name = "qt6gtk2";
    };
  };
}
