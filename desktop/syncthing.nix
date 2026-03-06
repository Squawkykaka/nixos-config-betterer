{ config, ... }:
{
  services.syncthing = {
    # breaks too much stuff
    enable = false;
    openDefaultPorts = true;
    user = "gleask";
    dataDir = "/home/gleask/.config/syncthing";
  };
}
