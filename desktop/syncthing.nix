{ config, ... }:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "gleask";
    dataDir = "/home/gleask/.config/syncthing";
  };
}
