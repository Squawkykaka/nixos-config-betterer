{config, ...}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = config.hostSpec.username;
    dataDir = "/home/${config.hostSpec.username}/.config/syncthing";
  };
}
