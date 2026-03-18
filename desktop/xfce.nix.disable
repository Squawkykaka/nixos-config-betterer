{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nitrogen
    pkgs.sxhkd
    pkgs.dunst
    pkgs.quickshell
    pkgs.libnotify
  ];
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.bspwm = {
      enable = true;
    };
  };
  # services.displayManager.defaultSession = "xfce";
}
