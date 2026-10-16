{
  hardware.nvidia-container-toolkit.enable = true;
  systemd.tmpfiles.rules = [
    "d /var/lib/frigate 0750 root root -"
    "d /var/lib/frigate/config 0750 root root -"
    "d /var/lib/frigate/storage 0750 root root -"
  ];

  users.groups.media.gid = 984;
  users.groups.frigate = { };
  users.users.frigate = {
    isSystemUser = true;
    group = "frigate";
    extraGroups = [ "media" ];
  };

  fileSystems."/mnt/media" = {
    device = "192.168.1.44:/volume1/linux-isos";
    fsType = "nfs";

    options = [
      "rw"
      "noatime"
      "hard"
      "_netdev"
      "nofail"
      "x-systemd.automount"
      "x-systemd.mount-timeout=30s"
    ];
  };

  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    autoStart = true;

    environment = {
      PUID = "1001";
      PGID = "1001";
    };

    ports = [
      "127.0.0.1:8971:8971"
      "8554:8554"
    ];

    volumes = [
      "/var/lib/frigate/config:/config"
      "/mnt/media/recordings:/media/frigate"
    ];

    extraOptions = [
      "--device=nvidia.com/gpu=all"
      "--stop-timeout=30"
      "--tmpfs=/tmp/cache:rw,size=1000000000"
    ];
  };

  # wait for nfs
  systemd.services.podman-frigate = {
    requires = [ "mnt-media.mount" ];
    after = [ "mnt-media.mount" ];
  };

  networking.firewall.allowedTCPPorts = [
    8554
  ];

  services.caddy.virtualHosts."frigate.squawkykaka.com" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:8971
    '';
  };
}
