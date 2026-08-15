{ config, ... }: {
  fileSystems."/mnt/media" = {
    device = "192.168.1.44:/volume1/linux-isos";
    fsType = "nfs";

    options = [
      "rw"
      "sec=sys"
      "noatime"
      "hard"
      "intr"
      "proto=tcp"
      "_netdev"
    ];
  };
  users.groups.media.gid = 984;
  users.users.qbittorrent.extraGroups = [ "media" ];
  users.users.gleask.extraGroups = [ "media" ];

  services.qbittorrent = {
    enable = true;
    webuiPort = 3056;
    torrentingPort = 7633;
  };

  services.caddy.virtualHosts."torrent.boom.boats".extraConfig = ''
    import trusted_only
    reverse_proxy 127.0.0.1:${toString config.services.qbittorrent.webuiPort} {
      header_up Host {host}
      header_up X-Forwarded-For {remote}
      header_up X-Forwarded-Host {host}
      header_up X-Forwarded-Proto {scheme}
      transport http {
        versions 1.1
      }
    }
  '';
}
