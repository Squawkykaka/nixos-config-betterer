{
  lib,
  pkgs,
  config,
  ...
}:
{
  services.cloud-init.network.enable = true;

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.timeout = 0; # Use the boot drive for GRUB
  boot.loader.grub.devices = [ "nodev" ];
  boot.growPartition = true;

  users.users.gleask.extraGroups = [ "acme" ];

  environment.systemPackages = with pkgs; [
    vim
  ];

  security.sudo.wheelNeedsPassword = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";

  virtualisation.docker.enable = true;
  services.caddy.virtualHosts."panel.smeagol.me".extraConfig = ''
    reverse_proxy 127.0.0.1:8793
  '';

  services.caddy.extraConfig = ''
    (trusted_only) {
      @not_trusted not remote_ip 10.0.0.0/8 192.168.0.0/16
      respond @not_trusted 403
    }
  '';

  services.invidious = {
    enable = true;
    domain = "invidious.boom.boats";
    database.passwordFile = config.sops.secrets."invidious/password".path;

    http3-ytproxy.enable = true;
    settings = {
      https_only = true;
      external_port = 443;

      invidious_companion = [
        {
          private_url = "http://localhost:8282/companion";
        }
      ];
      # Generate as per https://docs.invidious.io/installation/
      invidious_companion_key = "haedoh0eej1cev2U";
    };
  };
  virtualisation.oci-containers.containers = {
    invidious-companion = {
      image = "quay.io/invidious/invidious-companion:latest";
      ports = [ "127.0.0.1:8282:8282" ];
      volumes = [
        "companioncache:/var/tmp/youtubei.js:rw"
      ];
      environment = {
        # Same as configured on invidious above.
        SERVER_SECRET_KEY = "haedoh0eej1cev2U";
      };
    };
  };

  sops.secrets = {
    "cloudflare/api_token" = { };
    "bingbong/private_key" = { };
    "invidious/password" = { };
  };

  services.caddy.virtualHosts.${config.services.invidious.domain}.extraConfig = ''
    import trusted_only
    reverse_proxy 127.0.0.1:${toString config.services.invidious.port}
  '';

  sops.templates."matrix-caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      CLOUDFLARE_EMAIL=${config.sops.placeholder."email"}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
    '';
    #    owner = "caddy";
  };

  services.caddy = {
    enable = true;
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
    443
    9800
    7654
  ];
  networking.firewall.allowedUDPPorts = [
    7654
    9800
  ];

  security.acme.defaults.email = "contact@squawkykaka.com";
  security.acme.defaults.environmentFile = config.sops.templates."matrix-caddy-env".path;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.acceptTerms = true;

  kaka.servarr = {
    enable = true;
  };

  networking.nat = {
    enable = true;
    externalInterface = "ens18";
    internalInterfaces = [ "wg0" ];
  };

  users.users.wstunnel = {
    isSystemUser = true;
    group = "wstunnel";
  };
  users.groups.wstunnel = { };

  sops.secrets = {
    "wstunnel_secret" = { };
  };

  sops.templates."wstunnel-env" = {
    content = lib.generators.toKeyValue { } {
      WSTUNNEL_HTTP_UPGRADE_PATH_PREFIX = config.sops.placeholder."wstunnel_secret";
    };
  };

  systemd.services.wstunnel = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.wstunnel}/bin/wstunnel server --restrict-to localhost:51820 wss://0.0.0.0:9800";
      Restart = "always";
      EnvironmentFile = config.sops.templates."wstunnel-env".path;
      User = "wstunnel";
      Group = "wstunnel";
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
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.25.25.0/24 -o ens18 -j MASQUERADE
      '';

      #     # Undo the above
      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.25.25.0/24 -o ens18 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "OVx+WLrLyR/ShAYW3N2AiFRWJw+msbL4nBrJ+Z5u4VU=";
          allowedIPs = [ "10.25.25.3/32" ];
        }
        {
          publicKey = "6eW3uO3Yl+TXhNMTzVgoWebAcDVuORp631CzUa98hxs=";
          allowedIPs = [ "10.25.25.4/32" ];
        }
      ];
    };
  };
}
