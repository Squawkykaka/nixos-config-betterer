{ pkgs, self, ... }:
{
  programs.mangowc.enable = true;
  programs.mangowc.package = self.wrappers.mangowc.drv;

  services.displayManager.defaultSession = "mango";
  services.displayManager.sddm.theme = "sddm-astronaut-theme";
  services.displayManager.sddm.extraPackages = [ pkgs.qt6Packages.qtmultimedia ];

  environment.systemPackages = [
    pkgs.sddm-astronaut
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
