# this module sets up a matrix server with livekit, coturn, postgres and caddy using secrets defined using sops-nix,
{
  pkgs,
  lib,
  config,
  ...
}: let
  # this setup has everthing on a single host, this is the matrix server name.
  cfg = config.kaka.matrix;

  mkIf = lib.mkIf;
  mkOption = lib.mkOption;
  types = lib.types;
in {
  options.kaka.matrix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the fully setup matrix server
      '';
    };
    externalIp = mkOption {
      type = types.str;
      description = ''
        The external ip of the server
      '';
    };
    listeningIp = mkOption {
      type = types.str;
      description = ''
        The listening ip of the server
      '';
    };
    synapseUrl = mkOption {
      type = types.str;
      description = ''
        The url of the synapse server, without https://
      '';
    };
    synapseAdmin = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the synapse admin site.
        '';
      };
      url = mkOption {
        type = types.str;
        description = ''
          The url of the synapse admin server, without https://
        '';
      };
    };
    turn = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable setting up the turn relays automatically,
          without this enabled it will use the url given without setting up coturn.
        '';
      };
      url = mkOption {
        type = types.str;
        description = ''
          The url of the turn server, without https://
        '';
      };
    };
    metrics = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable sending metrics to synapse
      '';
    };
    livekit.enable = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to enable livekit setup
      '';
    };
  };

  config = mkIf cfg.enable {
    # secrets needed for setup.
    sops.secrets = {
      "synapse/registration_secret" = {};
      "synapse/turn_auth_secret" = {};
      "synapse/database_password" = {
        owner = config.systemd.services.postgresql.serviceConfig.User;
        restartUnits = ["postgresql.service"];
        mode = "0400";
      };
    };

    #
    # templates for configuration files
    #

    # synapse database configuration, everything needs to be defined here as synapse makes extra configs higher priority
    sops.templates."synapse-config" = {
      content = lib.generators.toYAML {} {
        registration_shared_secret = config.sops.placeholder."synapse/registration_secret";
        turn_shared_secret = config.sops.placeholder."synapse/turn_auth_secret";
        database = {
          name = "psycopg2";
          args = {
            dbname = "matrix-synapse";
            user = "matrix-synapse";
            host = "127.0.0.1";
            password = config.sops.placeholder."synapse/database_password";
            cp_min = 5;
            cp_max = 10;
            keepalives_idle = 10;
            keepalives_interval = 10;
            keepalives_count = 3;
          };
        };
      };
      owner = "matrix-synapse";
    };

    # coturn authentication secret.
    sops.templates."coturn-auth-secret" = {
      content = config.sops.placeholder."synapse/turn_auth_secret";
      owner = "turnserver";
    };

    #
    # livekit config
    #
    services.livekit = mkIf cfg.livekit.enable {
      enable = true;
      openFirewall = true;
      settings.room.auto_create = false;
      keyFile = "/run/livekit.key";
    };
    services.lk-jwt-service = mkIf cfg.livekit.enable {
      enable = true;
      # can be on the same virtualHost as synapse
      livekitUrl = "wss://smeagol.me/livekit/sfu";
      keyFile = "/run/livekit.key";
    };
    systemd.services.livekit-key = mkIf cfg.livekit.enable {
      before = [
        "lk-jwt-service.service"
        "livekit.service"
      ];
      wantedBy = ["multi-user.target"];
      path = with pkgs; [
        livekit
        coreutils
        gawk
      ];
      script = ''
        echo "Key missing, generating key"
        echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "/run/livekit.key"
      '';
      serviceConfig.Type = "oneshot";
      unitConfig.ConditionPathExists = "!/run/livekit.key";
    };
    systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS =
      mkIf cfg.livekit.enable "smeagol.me";

    #
    # Postgres config
    #
    services.postgresql = {
      enable = true;

      authentication = ''
        local   all             all             peer
        host    matrix-synapse  matrix-synapse  127.0.0.1/32  scram-sha-256
        host    matrix-synapse  matrix-synapse  ::1/128       scram-sha-256
      '';
    };
    # automatically setup the users and the database
    systemd.services.postgresql.postStart = let
      password_file_path = config.sops.secrets."synapse/database_password".path;
      db_name = "matrix-synapse";
      db_user = "matrix-synapse";
      psql = "${pkgs.postgresql}/bin/psql";
    in ''
      ${psql} -tA <<'EOF'
        DO $$
        DECLARE
          password TEXT;
          db_exists INT;
          user_exists INT;
        BEGIN
          password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));

          SELECT 1 INTO user_exists FROM pg_roles WHERE rolname='${db_user}';
          IF user_exists IS NULL THEN
            EXECUTE format('CREATE ROLE "${db_user}" WITH LOGIN PASSWORD '''%s''';', password);
          ELSE
            EXECUTE format('ALTER ROLE "${db_user}" WITH PASSWORD '''%s''';', password);
          END IF;
        END $$;
      EOF

      if ! ${psql} -lqt | cut -d \| -f 1 | grep -qw ${db_name}; then
        ${psql} -tAc "CREATE DATABASE \"${db_name}\" OWNER \"${db_user}\" ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
      fi
    '';

    #
    # synapse config
    #
    services.matrix-synapse = {
      enable = true;
      configureRedisLocally = true;

      extraConfigFiles = [
        config.sops.templates."synapse-config".path
      ];
      settings = {
        public_baseurl = "https://${cfg.synapseUrl}";
        server_name = cfg.synapseUrl;
        enable_metrics = true;
        turn_uris = [
          "turn:${cfg.turn.url}:3487?transport=udp"
          "turn:${cfg.turn.url}:3487?transport=tcp"
        ];
        redis.enabled = true;
      };
    };
    # load after postgres to make sure all databases and roles are setup
    systemd.services.matrix-synapse = {
      after = ["postgresql.service"];
      wants = ["postgresql.service"];
    };

    #
    # caddy config
    #
    services.caddy = {
      enable = true;
      virtualHosts."${cfg.synapseUrl}".extraConfig = ''
               # Client delegation
               header /.well-known/matrix/* Content-Type application/json
               respond /.well-known/matrix/server `{"m.server": "${cfg.synapseUrl}"}`
               respond /.well-known/matrix/client `${
          lib.generators.toJSON {} (
            {
              "m.homeserver".base_url = "https://${cfg.synapseUrl}";
              "org.matrix.msc3575.proxy".url = "https://${cfg.synapseUrl}";
            }
            # disabale livekit specifics if livekit is disabled
            // lib.optionals cfg.livekit.enable {
              "org.matrix.msc4143.rtc_foci" = [
                {
                  type = "livekit";
                  livekit_service_url = "https://${cfg.synapseUrl}/livekit/jwt";
                }
              ];
            }
          )
        }`
               # Reverse proxy Synapse
               reverse_proxy /_matrix/* localhost:8008
               reverse_proxy /_synapse/* localhost:8008

               ${lib.optionalString cfg.livekit.enable ''
          handle_path /livekit/jwt/* {
            reverse_proxy localhost:${toString config.services.lk-jwt-service.port}
          }
          handle_path /livekit/sfu/* {
            reverse_proxy localhost:${toString config.services.livekit.settings.port} {
              transport http {
                read_timeout 120s
                write_timeout 120s
              }

              header_up Accept-Encoding gzip
            }
          }
        ''}

        ${lib.optionalString cfg.synapseAdmin.enable ''
          handle_path /matrix/admin/* {
            @assets {
              path_regexp assets \.(css|js|jpg|jpeg|gif|png|svg|ico|woff|woff2|ttf|eot|webp)$
            }
            header @assets {
              Cache-Control "public"
            }

            @assets_expire {
              path_regexp assets \.(css|js|jpg|jpeg|gif|png|svg|ico|woff|woff2|ttf|eot|webp)$
            }
            header @assets_expire Cache-Control "public, max-age=2592000"

            root * ${
            pkgs.synapse-admin-etkecc.withConfig {
              restrictBaseUrl = [
                "https://${cfg.synapseUrl}"
              ];
            }
          }
            file_server
            encode gzip
          }
        ''}
      '';

      virtualHosts."${cfg.synapseUrl}:8448".extraConfig = ''
        reverse_proxy /_matrix/* localhost:8008
      '';
    };

    #
    # firewall config
    #
    networking.firewall.allowedTCPPorts =
      [
        # caddy
        443
      ]
      ++ lib.optionals cfg.turn.enable [
        # coturn
        3478
        5349
      ];
    # coturn
    networking.firewall.allowedUDPPorts = mkIf cfg.turn.enable [
      3478
      5349
    ];
    # coturn udp ports
    networking.firewall.allowedUDPPortRanges = mkIf cfg.turn.enable [
      {
        from = 49152;
        to = 65535;
      }
    ];

    #
    # coturn
    #
    services.coturn = mkIf cfg.turn.enable rec {
      enable = true;
      no-cli = true;
      realm = cfg.turn.url;
      use-auth-secret = true;
      static-auth-secret-file = config.sops.templates."coturn-auth-secret".path;
      cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
      pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
      no-tcp-relay = true;

      extraConfig = ''
        verbose
        external-ip=${cfg.externalIp}
        listening-ip=${cfg.listeningIp}
        # enable logging
        syslog

        denied-peer-ip=10.0.0.0-10.255.255.255
        denied-peer-ip=192.168.0.0-192.168.255.255
        denied-peer-ip=172.16.0.0-172.31.255.255

        no-multicast-peers
        denied-peer-ip=0.0.0.0-0.255.255.255
        denied-peer-ip=100.64.0.0-100.127.255.255
        denied-peer-ip=127.0.0.0-127.255.255.255
        denied-peer-ip=169.254.0.0-169.254.255.255
        denied-peer-ip=192.0.0.0-192.0.0.255
        denied-peer-ip=192.0.2.0-192.0.2.255
        denied-peer-ip=192.88.99.0-192.88.99.255
        denied-peer-ip=198.18.0.0-198.19.255.255
        denied-peer-ip=198.51.100.0-198.51.100.255
        denied-peer-ip=203.0.113.0-203.0.113.255
        denied-peer-ip=240.0.0.0-255.255.255.255
        denied-peer-ip=::1
        denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
        denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
        denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
        denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
        denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff

        allowed-peer-ip=${cfg.listeningIp}

        user-quota=12
        total-quota=1200
      '';
    };
    security.acme.certs."${config.services.coturn.realm}" = mkIf cfg.turn.enable {
      # insert here the right configuration to obtain a certificate
      postRun = "systemctl restart coturn.service";
      group = "turnserver";
    };
  };
}
