{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.kaka.servarr;
in
{
  options.kaka.servarr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the servarr setup.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "airvpn/private_key" = { };
      "airvpn/preshared_key" = { };
    };

    boot.supportedFilesystems = [
      "nfs"
    ];
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
    users.groups.media = {
      gid = 984;
    };
    users.users.jellyfin.extraGroups = [ "media" ];
    users.users.qbittorrent.extraGroups = [ "media" ];
    users.users.sonarr.extraGroups = [ "media" ];
    users.users.radarr.extraGroups = [ "media" ];
    users.users.lidarr.extraGroups = [ "media" ];
    # users.users.jackett.extraGroups = [ "media" ];
    users.users.gleask.extraGroups = [ "media" ];

    services.qbittorrent = {
      enable = true;
      webuiPort = 3056;
      torrentingPort = 7633;

      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "gleask";
            Address = "0.0.0.0";
            Password_PBKDF2 = "@ByteArray(MiU6Iy6AO7aGU4pBbtbRQg==:FCuR9YzVgNZgFHmNTNR+HIJxqpQqN5pCZ4Fl0xqYxhDyNT3gbTiUOzPhXow9bqZrq+0iz7Es+T0ylV0bSlXr3Q==)";

            # AlternativeUIEnabled = true;
            # RootFolder = "${pkgs.vuetorrent}/share/vuetorrent";
          };
          Session = {
            Interface = "wg-qbittorrent";
            InterfaceName = "wg-qbittorrent";

            TorrentExportDirectory = "/mnt/media/downloads/torrents";
            DefaultSavePath = "/mnt/media/downloads";
            TempPath = "/mnt/media/downloads/temp";

            ExcludedFileNames = "*.lnk, *.scr, *.arj";
          };
        };
      };
    };
    services.caddy.virtualHosts."torrent.smeagol.me".extraConfig = ''
      import trusted_only
      reverse_proxy 10.200.200.2:${toString config.services.qbittorrent.webuiPort} {
        header_up Host {host}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Host {host}
        header_up X-Forwarded-Proto {scheme}
        transport http {
          versions 1.1
        }
      }
    '';

    services.jellyfin.enable = true;
    services.caddy.virtualHosts."jellyfin.smeagol.me".extraConfig = ''
      reverse_proxy localhost:8096 {
        # transport http {
        #   versions 1.1
        # }
      }
    '';
    networking.firewall = {
      allowedTCPPorts = [
        # 8096
        8920
      ];
      allowedUDPPorts = [
        1900
        7359
      ];
    };

    services.radarr = {
      enable = true;
    };
    services.caddy.virtualHosts."radarr.smeagol.me".extraConfig = ''
      import trusted_only
      reverse_proxy localhost:${toString config.services.radarr.settings.server.port}
    '';

    services.prowlarr.enable = true;
    services.caddy.virtualHosts."prowlarr.smeagol.me".extraConfig = ''
      import trusted_only
      reverse_proxy localhost:${toString config.services.prowlarr.settings.server.port}
    '';

    services.sonarr.enable = true;
    services.caddy.virtualHosts."sonarr.smeagol.me".extraConfig = ''
      import trusted_only
      reverse_proxy localhost:${toString config.services.sonarr.settings.server.port}
    '';

    services.lidarr.enable = true;
    services.caddy.virtualHosts."lidarr.smeagol.me".extraConfig = ''
      import trusted_only
      reverse_proxy localhost:${toString config.services.lidarr.settings.server.port}
    '';

    services.flaresolverr.enable = true;
  };
}
