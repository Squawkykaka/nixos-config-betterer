{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.services.tdarr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    server = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    node = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.services.tdarr.enable {
    users.users.tdarr = {
      isSystemUser = true;
      group = "tdarr";
      extraGroups = [ "media" ];
    };
    users.groups.tdarr = { };

    systemd.tmpfiles.rules = [
      "d /var/lib/tdarr 0700 tdarr tdarr -"
      "d /var/lib/tdarr/configs 0700 tdarr tdarr -"
      "d /var/log/tdarr 0700 tdarr tdarr -"
      "d /var/lib/transcode-cache 0700 tdarr tdarr -"
    ];

    virtualisation.oci-containers.containers = {
      tdarr-server = lib.mkIf config.services.tdarr.server {
        image = "ghcr.io/haveagitgat/tdarr:latest";
        # user = "tdarr:tdarr";
        ports = [
          "8265:8265"
          "8266:8266"
        ];
        volumes = [
          "/var/log/tdarr:/app/logs"
          "/var/lib/tdarr:/app/server"
          "/var/lib/tdarr/configs:/app/configs"
          "/mnt/media:/media"
        ];
        environment = {
          TZ = "Pacific/Auckland";
          PUID = "985";
          PGUID = "978";
          UMASK_SET = "002";
          serverIP = "0.0.0.0";
          serverPort = "8266";
          webUIPort = "8265";
          inContainer = "true";
          ffmpegVersion = "7";

          maxLogSizeMB = "10";

          # NVIDIA_DRIVER_CAPABILITIES="all";
          # NVIDIA_VISIBLE_DEVICES="all";
        };
        extraOptions = [ "--group-add=984" ];
        # devices = [ "/dev/dri:/dev/dri" ];
      };
      tdarr-node = {
        image = "ghcr.io/haveagitgat/tdarr_node:latest";
        # user = "tdarr:tdarr";
        environment = {
          TZ = "Pacific/Auckland";
          PUID = "985";
          PGUID = "978";
          UMASK_SET = "002";
          nodeName = "GamingPC";
          serverIP = "host.containers.internal";
          serverPort = "8266";
          inContainer = "true";
          ffmpegVersion = "7";
          nodeType = "mapped";
          priority = "-1";
          maxLogSizeMB = "10";
          pollInterval = "2000";
          startPaused = "true";
          transcodegpuWorkers = "2";
          transcodecpuWorkers = "1";
          healthcheckgpuWorkers = "1";
          healthcheckcpuWorkers = "1";
          NVIDIA_DRIVER_CAPABILITIES = "all";
          NVIDIA_VISIBLE_DEVICES = "all";
        };
        volumes = [
          "/var/lib/tdarr/configs:/app/configs"
          "/var/log/tdarr:/app/logs"
          "/var/lib/transcode-cache:/temp"
          "/mnt/media:/media"
        ];
        devices = [ "/dev/dri:/dev/dri" ];
        extraOptions = [ "--group-add=984" ];
      };
    };
  };
}
