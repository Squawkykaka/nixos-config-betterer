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
}
