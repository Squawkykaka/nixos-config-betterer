{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # xwayland.enable = true;

    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  security.pam.services.hyprlock = { };
}
