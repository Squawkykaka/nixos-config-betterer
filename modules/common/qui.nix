{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.qui;

  stripNulls = lib.filterAttrsRecursive (_: v: v != null);

  renderedConfig = stripNulls cfg.settings;

  logDir = builtins.dirOf cfg.settings.logPath;
in
{
  options.services.qui = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the qui service.
      '';
    };

    package = lib.mkPackageOption pkgs "QUI" { default = [ "qui" ]; };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qui";
      description = "User account under which qui runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "qui";
      description = "Group account under which qui runs.";
    };

    settings = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options = {
          host = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            example = "0.0.0.0";
            description = "Bind address for the main web interface.";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 7476;
            example = 8080;
            description = "Port for the main web interface.";
          };

          baseUrl = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "/qui/";
            description = "Optional base URL path.";
          };

          sessionSecret = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "a3c9f8f6c1d24b9b82cbb41c2f0a9b7e";
            description = "Secret used to encrypt stored passwords.";
          };

          logPath = lib.mkOption {
            type = lib.types.path;
            default = "/var/log/qui/latest.log";
            example = "/var/log/qui/latest.log";
            description = "Log file path.";
          };

          logMaxSize = lib.mkOption {
            type = lib.types.int;
            default = 50;
            example = 100;
            description = "Maximum log size in MB before rotation.";
          };

          logMaxBackups = lib.mkOption {
            type = lib.types.int;
            default = 3;
            example = 10;
            description = "Number of rotated log files to retain.";
          };

          dataDir = lib.mkOption {
            type = lib.types.path;
            default = "/var/lib/qui";
            example = "/var/lib/qui";
            description = "Persistent data directory.";
          };

          checkForUpdates = lib.mkOption {
            type = lib.types.bool;
            default = true;
            example = false;
            description = "Enable update checks.";
          };

          logLevel = lib.mkOption {
            type = lib.types.enum [
              "ERROR"
              "DEBUG"
              "INFO"
              "WARN"
              "TRACE"
            ];
            default = "INFO";
            example = "DEBUG";
            description = "Application log level.";
          };

          metricsEnabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Enable Prometheus metrics.";
          };

          metricsHost = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            example = "0.0.0.0";
            description = "Metrics bind address.";
          };

          metricsPort = lib.mkOption {
            type = lib.types.port;
            default = 9074;
            example = 9090;
            description = "Metrics server port.";
          };

          metricsBasicAuthUsers = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "prometheus:$2y$10$abcdefghijklmnopqrstuv";
            description = "Basic auth users for metrics endpoint.";
          };

          externalProgramAllowList = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [ ];
            example = [
              "/usr/local/bin/my-script"
              "/home/user/bin"
            ];
            description = "Allow list for external programs.";
          };

          oidcEnabled = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Enable OIDC authentication.";
          };

          oidcIssuer = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "https://auth.example.com";
            description = "OIDC issuer URL.";
          };

          oidcClientId = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "qui";
            description = "OIDC client ID.";
          };

          oidcClientSecret = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "super-secret-client-secret";
            description = "OIDC client secret.";
          };

          oidcRedirectUrl = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "https://qui.example.com/api/auth/oidc/callback";
            description = "OIDC redirect URL.";
          };

          oidcDisableBuiltInLogin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            example = true;
            description = "Disable built-in login when OIDC is enabled.";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.settings.oidcEnabled == false
          || (
            cfg.settings.oidcIssuer != ""
            && cfg.settings.oidcClientId != ""
            && cfg.settings.oidcClientSecret != ""
            && cfg.settings.oidcRedirectUrl != ""
          );
        message = "OIDC is enabled, but required OIDC fields are missing.";
      }

      {
        assertion = cfg.settings.metricsBasicAuthUsers == "" || cfg.settings.metricsEnabled == true;
        message = "metricsBasicAuthUsers is set, but metricsEnabled is false.";
      }

      {
        assertion = cfg.settings.metricsEnabled == false || cfg.settings.metricsPort != 0;
        message = "metricsEnabled is true but metricsPort is invalid.";
      }
    ];

    users.users = lib.optionalAttrs (cfg.user == "qui") {
      qui = {
        description = "qui user";
        home = cfg.settings.dataDir;
        group = cfg.group;
        isSystemUser = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == "qui") {
      qui = { };
    };
    systemd = {
      tmpfiles.settings.quiDirs = {
        "${cfg.settings.dataDir}"."d" = {
          mode = "700";
          inherit (cfg) user group;
        };
        "${logDir}"."d" = {
          mode = "700";
          inherit (cfg) user group;
        };
      };
    };

    environment.etc."qui/config.toml".source = pkgs.writers.writeTOML "config.toml" renderedConfig;

    systemd.services.qui = {
      description = "Qui Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        # FIXME change to get mainexe path lib.getEXE
        ExecStart = "${cfg.package}/bin/qui serve --config-dir /etc/qui/config.toml";
        Restart = "always";
        RestartSec = 5;
        User = cfg.user;
        Group = cfg.group;

        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ReadWritePaths = [
          cfg.settings.dataDir
          logDir
        ];
      };
    };
  };
}
