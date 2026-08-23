{ pkgs, self, ... }:
{
  programs.niri.enable = true;
  programs.niri.package = self.wrappers.niri.drv;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";

    extraPackages = [ pkgs.qt6Packages.qtmultimedia ];
  };
  services.displayManager.defaultSession = "niri";

  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.sddm-astronaut
    pkgs.kdePackages.spectacle
    pkgs.libnotify
    self.wrappers.quickshell.drv
  ];

  security.polkit.enable = true;
}
