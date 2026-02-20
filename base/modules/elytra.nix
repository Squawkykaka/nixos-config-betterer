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
      default = "elytra";
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

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port Elytra listens on.";
    };
  };

  config = mkIf cfg.enable {
    users.users.elytra = mkIf (cfg.user == "elytra") {
      isSystemUser = true;
      group = cfg.group;
      description = "Elytra daemon user";
    };

    systemd.tmpfiles.rules = [ "d /etc/elytra 600 ${cfg.user} ${cfg.group}" ];

    users.groups.${cfg.group} = { };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    # docker is needed for elytra
    virtualisation.docker.enable = true;

    systemd.services.elytra = {
      description = "Pyrodactyl Elytra Daemon";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      partOf = [ "docker.service" ];

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
      };
    };
  };
}
