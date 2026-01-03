{
  lib,
  pkgs,
  config,
  wrappers,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ]
  ++ (map lib.custom.relativeToRoot [
    "hosts/common/core"
    "modules/common"
  ]);

  hostSpec = {
    hostName = "bingbong";
    username = "gleask";
    persistFolder = "/persist";
  };

  services.cloud-init.network.enable = true;

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.timeout = 0; # Use the boot drive for GRUB
  boot.loader.grub.devices = [ "nodev" ];
  boot.growPartition = true;

  environment.systemPackages = with pkgs; [
    vim
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
    "cloudflare/api_token" = { };
    "searxng/secret_key" = { };
    "bingbong/private_key" = { };
  };

  sops.templates."matrix-caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      CLOUDFLARE_EMAIL=${config.sops.placeholder."email"}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
    '';
    #    owner = "caddy";
  };
  sops.templates."searxng-environment" = {
    content = lib.generators.toKeyValue { } {
      SEARXNG_SECRET = config.sops.placeholder."searxng/secret_key";
      SEARXNG_VALKEY_URL = "unix://${config.services.redis.servers.searx.unixSocket}";
    };
  };

  services.caddy = {
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
    };

    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.sops.templates."matrix-caddy-env".path
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    7654
  ];
  networking.firewall.allowedUDPPorts = [ 7654 ];

  security.acme.defaults.email = "contact@squawkykaka.com";
  security.acme.defaults.environmentFile = config.sops.templates."matrix-caddy-env".path;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.acceptTerms = true;

  kaka.matrix = {
    enable = true;
    externalIp = "203.211.120.109";
    listeningIp = "10.0.0.76";
    synapseUrl = "smeagol.me";
    turn.url = "turn.smeagol.me";
    synapseAdmin = {
      enable = true;
      url = "admin.smeagol.me";
    };
    metrics = true;
  };

  kaka.servarr = {
    enable = true;
  };

  services.calibre-web = {
    enable = true;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
      calibreLibrary = "/var/lib/calibre-web/library";
    };
  };

  services.caddy.virtualHosts."calibre.smeagol.me".extraConfig = ''
    reverse_proxy localhost:${toString config.services.calibre-web.listen.port}
  '';

  services.caddy.virtualHosts."search.boom.boats".extraConfig = ''
    reverse_proxy 127.0.0.1:8888
  '';

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    environmentFile = config.sops.templates."searxng-environment".path;
    settingsFile = ./searxng.yml;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
  };

  sops.secrets."shadowsocks/password" = { };
  sops.templates."shadowsocks-env" = {
    content = lib.generators.toKeyValue { } {
      PASSWORD_ENV = config.sops.placeholder."shadowsocks/password";
    };
  };
  systemd.services.shadowsocks = {
    wantedBy = [ "multi-user.target" ];
    path = [ wrappers.ssserver ];
    serviceConfig = {
      EnvironmentFile = config.sops.templates."shadowsocks-env".path;
      ExecStart = "${wrappers.ssserver}/bin/ssserver";
    };
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      #     # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      privateKeyFile = config.sops.secrets."bingbong/private_key".path;
      address = [ "10.25.25.1/32" ];
      listenPort = 51820;
      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.25.25.0/32 -o ens18 -j MASQUERADE
      '';

      #     # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.25.25.0/32 -o ens18 -j MASQUERADE
      '';
    };
  };

  # sops.secrets = {
  #   "peertube/redis_pass" = {
  #     group = "peertube";
  #     mode = "0400";
  #   };
  #   "peertube/postgres_pass" = {
  #     owner = "postgres";
  #     group = "peertube";
  #     mode = "0400";
  #   };
  #   "peertube/secret_file" = {
  #     # owner = "postgres";
  #     group = "peertube";
  #     mode = "0400";
  #   };
  # };

  # services.peertube = {
  #   enable = true;
  #   localDomain = "tube.smeagol.me";
  #   enableWebHttps = false;
  #   database = {
  #     host = "127.0.0.1";
  #     name = "peertube_local";
  #     user = "peertube";
  #     passwordFile = config.sops.secrets."peertube/postgres_pass".path;
  #   };
  #   redis = {
  #     host = "127.0.0.1";
  #     port = 31638;
  #     passwordFile = config.sops.secrets."peertube/redis_pass".path;
  #   };
  #   settings = {
  #     listen.hostname = "0.0.0.0";
  #     instance.name = "Squawkykaka PeerTube Server";
  #   };
  #   secrets.secretsFile = config.sops.secrets."peertube/secret_file".path;
  # };

  # services.postgresql = {
  #   enable = true;
  #   enableTCPIP = true;

  #   authentication = ''
  #     hostnossl peertube_local peertube 127.0.0.1/32 md5
  #   '';

  #   initialScript = pkgs.writeText "postgresql_init.sql" ''
  #     CREATE DATABASE peertube_local TEMPLATE template0 ENCODING UTF8;
  #     \connect peertube_local
  #     CREATE EXTENSION IF NOT EXISTS pg_trgm;
  #     CREATE EXTENSION IF NOT EXISTS unaccent;
  #   '';
  # };

  # # Create peertube role securely at runtime
  # systemd.services.init-peertube-postgres = {
  #   description = "Create PostgreSQL user for PeerTube using secret password";
  #   after = [ "postgresql.service" ];
  #   wantedBy = [ "multi-user.target" ];

  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "postgres";
  #   };

  #   script = ''
  #           PASS="$(cat ${config.sops.secrets."peertube/postgres_pass".path})"

  #           ${pkgs.postgresql}/bin/psql -c "CREATE DATABASE peertube_local TEMPLATE template0 ENCODING UTF8;"
  #           ${pkgs.postgresql}/bin/psql <<EOF
  #     DO
  #     $$
  #     BEGIN
  #        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'peertube') THEN
  #           CREATE ROLE peertube LOGIN PASSWORD '$PASS';
  #        END IF;
  #     END
  #     $$;
  #     EOF

  #           # Ensure permissions
  #           ${pkgs.postgresql}/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE peertube_local TO peertube;"
  #           ${pkgs.postgresql}/bin/psql -c "ALTER DATABASE peertube_local OWNER TO peertube;"
  #   '';
  # };

  # # --- Redis ---
  # services.redis.servers.peertube = {
  #   enable = true;
  #   bind = "0.0.0.0"; # or "127.0.0.1" if not needed externally
  #   port = 31638;
  #   requirePassFile = config.sops.secrets."peertube/redis_pass".path;
  # };
}
