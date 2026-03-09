{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.minerva;
in
{
  options.services.minerva = {
    enable = lib.mkEnableOption "Elytra daemon";
    package = lib.mkPackageOption pkgs "minerva-worker";
    user = lib.mkOption {
      type = lib.types.str;
      default = "minerva";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "minerva";
    };
    # TODO: add options for some of the environment variables
  };

  config = lib.mkIf cfg.enable {
    users.groups = lib.optionalAttrs (cfg.group == "minerva") { "${cfg.group}" = { }; };
    users.users = lib.optionalAttrs (cfg.user == "minerva") {
      "${cfg.user}" = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    systemd.services.minerva = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        MINERVA_TEMP_DIR = "/var/lib/minerva/temp_dir";
        MINERVA_TOKEN_FILE = "/var/lib/minerva/token";
        MINERVA_CACHE_FILE = "/var/lib/minerva/cache";
      };

      serviceConfig = {
        ExecStart = "${pkgs.minerva-worker}/bin/minerva";
        Restart = "always";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "/var/lib/minerva";
        StateDirectory = "minerva";
      };
    };
  };
}
