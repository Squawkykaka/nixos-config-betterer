{
  lib,
  pkgs,
  config,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
    ]
    ++ (map lib.custom.relativeToRoot [
      "hosts/common/core"
    ]);

  hostSpec = {
    hostName = "bingbong";
    username = "gleask";
    persistFolder = "/persist";
  };

  services.cloud-init.network.enable = true;

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.timeout = 0; # Use the boot drive for GRUB
  boot.loader.grub.devices = ["nodev"];
  boot.growPartition = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  programs.ssh.startAgent = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";

  sops.secrets = {
    "synapse/registration_secret" = {};
    "synapse/turn_auth_secret" = {};
    "cloudflare/api_token" = {};
    "synapse/database_password" = {
      owner = config.systemd.services.postgresql.serviceConfig.User;
      restartUnits = ["postgresql.service"];
      mode = "0400";
    };
  };

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
  sops.templates."coturn-auth-secret" = {
    content = config.sops.placeholder."synapse/turn_auth_secret";
    owner = "turnserver";
  };
  sops.templates."matrix-caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      CLOUDFLARE_EMAIL=${config.sops.placeholder."email"}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
    '';
    owner = "caddy";
  };

  services.livekit = {
    enable = true;
    openFirewall = true;
    settings.room.auto_create = false;
    keyFile = "/run/livekit.key";
  };
  services.lk-jwt-service = {
    enable = true;
    # can be on the same virtualHost as synapse
    livekitUrl = "wss://smeagol.me/livekit/sfu";
    keyFile = "/run/livekit.key";
  };
  systemd.services.livekit-key = {
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
  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "smeagol.me";

  services.postgresql = {
    enable = true;

    authentication = ''
      local   all             all             peer
      host    matrix-synapse  matrix-synapse  127.0.0.1/32  scram-sha-256
      host    matrix-synapse  matrix-synapse  ::1/128       scram-sha-256
    '';
  };

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

  services.matrix-synapse = {
    enable = true;
    configureRedisLocally = true;

    extraConfigFiles = [config.sops.templates."synapse-config".path];
    settings = {
      public_baseurl = "https://smeagol.me";
      server_name = "smeagol.me";
      enable_metrics = true;
      turn_uris = [
        "turn:turn.smeagol.me:3487?transport=udp"
        "turn:turn.smeagol.me:3487?transport=tcp"
      ];
      redis.enabled = true;
    };
  };

  systemd.services.matrix-synapse = {
    after = ["postgresql.service"];
    wants = ["postgresql.service"];
  };

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
      hash = "sha256-ea8PC/+SlPRdEVVF/I3c1CBprlVp1nrumKM5cMwJJ3U=";
    };
    virtualHosts."smeagol.me".extraConfig = ''
      # Client delegation
      header /.well-known/matrix/* Content-Type application/json
      header /.well-known/matrix/* Access-Control-Allow-Origin *
      respond /.well-known/matrix/server `{"m.server": "smeagol.me"}`
      respond /.well-known/matrix/client `${
        lib.generators.toJSON {} {
          "m.homeserver".base_url = "https://smeagol.me";
          "org.matrix.msc3575.proxy".url = "https://smeagol.me";
          "org.matrix.msc4143.rtc_foci" = [
            {
              type = "livekit";
              livekit_service_url = "https://smeagol.me/livekit/jwt";
            }
          ];
        }
      }`
      # Reverse proxy Synapse
      reverse_proxy /_matrix/* localhost:8008
      reverse_proxy /_synapse/client/* localhost:8008
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
    '';

    virtualHosts."smeagol.me:8448".extraConfig = ''
      reverse_proxy /_matrix/* localhost:8008
    '';

    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.sops.templates."matrix-caddy-env".path
  ];

  networking.firewall.allowedTCPPorts = [
    443
    8448
    3478
    5349
    22
  ];
  networking.firewall.enable = true;
  networking.firewall.allowedUDPPorts = [
    3478
    5349
  ];
  networking.firewall.allowedUDPPortRanges = [
    {
      from = 49152;
      to = 65535;
    }
  ];

  services.coturn = rec {
    enable = true;
    no-cli = true;
    realm = "turn.smeagol.me";
    use-auth-secret = true;
    static-auth-secret-file = config.sops.templates."coturn-auth-secret".path;
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    no-tcp-relay = true;

    extraConfig = ''
      verbose
      external-ip=203.211.120.109
      listening-ip=10.0.0.76
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

      allowed-peer-ip=10.0.0.76

      user-quota=12
      total-quota=1200
    '';
  };
  security.acme.defaults.email = "contact@squawkykaka.com";
  security.acme.defaults.environmentFile = config.sops.templates."matrix-caddy-env".path;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.acceptTerms = true;
  security.acme.certs."${config.services.coturn.realm}" = {
    # insert here the right configuration to obtain a certificate
    postRun = "systemctl restart coturn.service";
    group = "turnserver";
  };
}
