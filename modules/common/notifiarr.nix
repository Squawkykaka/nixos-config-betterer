{
  config,
  lib,
  ...
}:
let
  cfg = config.services.notifiarr;
in
{
  options.services.notifiarr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the Notifiarr service.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5454;
      description = "Port for the Notifiarr web interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      tmpfiles.settings.notifiarrDirs = {
        "/var/lib/notifiarr"."d" = {
          mode = "700";
          user = "root";
          # inherit (cfg) user group;
        };
        # "${logDir}"."d" = {
        #   mode = "700";
        #   inherit (cfg) user group;
        # };
      };
    };

    virtualisation.oci-containers.containers.notifiarr = {
      image = "golift/notifiarr";
      ports = [ "0.0.0.0:${toString cfg.port}:5454" ];
      volumes = [
        "/var/lib/notifiarr:/config"
        "/var/run/utmp:/var/run/utmp"
        "/etc/machine-id:/etc/machine-id"
      ];
    };
  };
}
