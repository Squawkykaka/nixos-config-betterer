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
    pkgs.sddm-astronaut
    pkgs.kdePackages.spectacle
    pkgs.libnotify
    self.wrappers.quickshell.drv
  ];

  environment.variables = {
    XCURSOR_THEME = "BreezeX-Dark";
    XCURSOR_SIZE = 24;
  };

  security.polkit.enable = true;

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
