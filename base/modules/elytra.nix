{
  config,
  lib,
  pkgs,
  self,
  ...
}:

with lib;

let
  cfg = config.services.elytra;
in
{
  options.services.elytra = {
    enable = mkEnableOption "Elytra daemon";

    package = mkOption {
      type = types.package;
      default = self.myPkgs.elytra;
      description = "Elytra package to use.";
    };

    user = mkOption {
      type = types.str;
      default = "pyrodactyl";
      description = "User account under which Elytra runs.";
    };

    group = mkOption {
      type = types.str;
      default = "elytra";
      description = "Group for Elytra.";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/elytra";
      description = "Working directory for Elytra.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Open Elytra port in firewall.";
    };
  };

  config = mkIf cfg.enable {
    users.users.pyrodactyl = mkIf (cfg.user == "pyrodactyl") {
      isSystemUser = true;
      group = cfg.group;
      description = "Elytra daemon user";
      extraGroups = [ "docker" ];
    };

    systemd.tmpfiles.rules = [
      "d /etc/elytra 0750 ${cfg.user} ${cfg.group}"
      # "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group}"
      "d /var/log/elytra 0750 ${cfg.user} ${cfg.group}"
      "d /tmp/elytra 0750 ${cfg.user} ${cfg.group}"
    ];

    users.groups.elytra = mkIf (cfg.group == "elytra") { };

    # docker is needed for elytra
    virtualisation.docker.enable = true;

    systemd.services.elytra = {
      description = "Pyrodactyl Elytra Daemon";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];

      environment.TMPDIR = toString "/run/elytra";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        PIDFile = "/run/elytra/daemon.pid";

        ExecStart = "${cfg.package}/bin/elytra";

        Restart = "on-failure";
        RestartSec = 5;

        LimitNOFILE = 4096;
        StateDirectory = "elytra";
        AmbientCapabilities = [ "CAP_CHOWN" ];
        CapabilityBoundingSet = [ "CAP_CHOWN" ];
        NoNewPrivileges = false;
      };
    };
  };
}
