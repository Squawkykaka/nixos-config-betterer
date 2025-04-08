{
  networking.networkmanager.enable = true;
  networking.enableIPv6  = false;

  # disable networmanager wait
  systemd.services.NetworkManager-wait-online.enable = false;
}
