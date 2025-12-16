{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.networkmanagerapplet
  ];

  services.gnome.gnome-keyring.enable = true;

  programs.hyprland = {
    enable = true;
    # xwayland.enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = [
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
    ];
  };

  security.pam.services.hyprlock = {};

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
