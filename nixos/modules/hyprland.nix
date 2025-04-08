{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # xwayland.enable = false;
  };

  security.pam.services.hyprlock = {};
}
