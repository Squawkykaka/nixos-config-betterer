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

      neededForBoot = false;
    };
    users.groups.media = {
      gid = 984;
    };
    users.users.jellyfin.extraGroups = [ "media" ];
    users.users.qbittorrent.extraGroups = [ "media" ];
    users.users.sonarr.extraGroups = [ "media" ];
    users.users.radarr.extraGroups = [ "media" ];
    users.users.lidarr.extraGroups = [ "media" ];
    # users.users.jackett.extraGroups = ["media"];
    users.users.gleask.extraGroups = [ "media" ];

    networking.wireguard.interfaces.wg-qbittorrent = {
      # Use a separate network namespace for the VPN.
      # sudo ip netns exec wg-qbittorrent curl --interface wg-mullvad https://am.i.mullvad.net/connected

      privateKeyFile = config.sops.secrets."airvpn/private_key".path;
      mtu = 1320;
      ips = [
        "10.149.200.203/32"
        "fd7d:76ee:e68f:a993:95ea:4506:fd92:e338/128"
      ];
      interfaceNamespace = "wg-qbittorrent";

      preSetup = ''
        ip netns add wg-qbittorrent
        ip -n wg-qbittorrent link set lo up

        # Create a veth pair to link the namespaces
        ip link add veth-host type veth peer name veth-vpn
        ip link set veth-vpn netns wg-qbittorrent
        ip addr add 10.200.200.1/24 dev veth-host
        ip netns exec wg-qbittorrent ip addr add 10.200.200.2/24 dev veth-vpn
        ip link set veth-host up
        ip netns exec wg-qbittorrent ip link set veth-vpn up
        ip netns exec wg-qbittorrent ip route add default via 10.200.200.1
      '';

      postShutdown = ''
           # Delete the veth pair
        ip link del veth-host

           # Delete the namespace
        ip netns del wg-qbittorrent
      '';

      peers = [
        {
          publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
          allowedIPs = [
            "0.0.0.0/0"
            "::0/0"
          ];
          presharedKeyFile = config.sops.secrets."airvpn/preshared_key".path;
          endpoint = "nz3.vpn.airdns.org:1637";
          persistentKeepalive = 15;
        }
      ];
    };

    services.qui = {
      enable = true;
      package = pkgs.qui;
      settings.sessionSecret = "FCuR9YzVgNZgFHmNTNR";
      settings.baseUrl = "/qui/";
    };
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
    systemd.services.qbittorrent.serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/wg-qbittorrent";
    };
    services.caddy.virtualHosts."torrent.smeagol.me".extraConfig = ''
      handle /qui {
        redir /qui/ permanent
      }

      # Qui on port 7476
      handle /qui/* {
        reverse_proxy 127.0.0.1:7476 {
          header_up Host {host}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Host {host}
          header_up X-Forwarded-Proto {scheme}
        }
      }

      # qBittorrent - must come last as catch-all
      handle /* {
        reverse_proxy 10.200.200.2:${toString config.services.qbittorrent.webuiPort} {
          header_up Host {host}
          header_up X-Forwarded-For {remote}
          header_up X-Forwarded-Host {host}
          header_up X-Forwarded-Proto {scheme}
          transport http {
            versions 1.1
          }
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
      reverse_proxy localhost:${toString config.services.radarr.settings.server.port}
    '';

    services.prowlarr.enable = true;
    services.caddy.virtualHosts."prowlarr.smeagol.me".extraConfig = ''
      reverse_proxy localhost:${toString config.services.prowlarr.settings.server.port}
    '';

    services.sonarr.enable = true;
    services.caddy.virtualHosts."sonarr.smeagol.me".extraConfig = ''
      reverse_proxy localhost:${toString config.services.sonarr.settings.server.port}
    '';

    services.lidarr.enable = true;
    services.caddy.virtualHosts."lidarr.smeagol.me".extraConfig = ''
      reverse_proxy localhost:${toString config.services.lidarr.settings.server.port}
    '';

    services.jellyseerr.enable = true;
    services.caddy.virtualHosts."jellyseerr.smeagol.me".extraConfig = ''
      reverse_proxy localhost:${toString config.services.jellyseerr.port}
    '';

    # services.jackett.enable = true;
    # services.caddy.virtualHosts."jackett.smeagol.me".extraConfig = ''
    #   @local {
    #       remote_ip 10.0.0.0/8
    #       remote_ip 172.16.0.0/12
    #       remote_ip 192.168.0.0/16
    #   }
    #   handle @local {
    #       reverse_proxy localhost:${toString config.services.jackett.port}
    #   }
    #   handle {
    #       respond "Forbidden" 403
    #   }
    # '';

    sops.secrets = {
      "autobrr/secret" = { };
    };
    # services.notifiarr.enable = true;
    services.autobrr = {
      enable = true;
      secretFile = config.sops.secrets."autobrr/secret".path;
    };
    services.caddy.virtualHosts."autobrr.smeagol.me".extraConfig = ''
      reverse_proxy localhost:${toString config.services.autobrr.settings.port}
    '';

    services.flaresolverr.enable = true;
  };
}
