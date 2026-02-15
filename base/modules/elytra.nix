{
  config,
  lib,
  pkgs,
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
      default = pkgs.elytra;
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

    panelUrl = mkOption {
      type = types.str;
      description = "Pyrodactyl panel URL.";
    };

    tokenFile = mkOption {
      type = types.path;
      description = "Path to file containing Elytra node token.";
    };

    nodeId = mkOption {
      type = types.int;
      description = "Node ID from panel.";
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

    useACME = mkOption {
      type = types.bool;
      default = false;
      description = "Use NixOS ACME integration for SSL.";
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain for ACME certificate.";
    };

    enableRustic = mkOption {
      type = types.bool;
      default = false;
      description = "Enable rustic for backups.";
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.useACME -> cfg.domain != null;
        message = "services.elytra.domain must be set when useACME = true";
      }
    ];

    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      # shell = pkgs.shadow.nologin;
      description = "Elytra daemon user";
    };

    users.groups.${cfg.group} = { };

    environment.systemPackages = optional cfg.enableRustic pkgs.rustic;

    security.acme = mkIf cfg.useACME {
      certs.${cfg.domain} = {
        group = cfg.group;
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.elytra = {
      description = "Pyrodactyl Elytra Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;

        ExecStartPre = ''
          ${cfg.package}/bin/elytra configure \
            --panel-url ${cfg.panelUrl} \
            --token "$(cat ${cfg.tokenFile})" \
            --node ${toString cfg.nodeId}
        '';

        ExecStart = "${cfg.package}/bin/elytra";

        Restart = "on-failure";
        RestartSec = 5;

        LimitNOFILE = 4096;
        StateDirectory = "elytra";
      };
    };
  };
}
