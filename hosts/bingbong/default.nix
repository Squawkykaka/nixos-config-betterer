{
  lib,
  pkgs,
  config,
  self,
  ...
}:
{
  services.cloud-init.network.enable = true;

  networking.nameservers = [
    "10.0.0.1"
    "2401:7000:d900:5::3a4"
  ];
  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.timeout = 0; # Use the boot drive for GRUB
  boot.loader.grub.devices = [ "nodev" ];
  boot.growPartition = true;

  users.users.gleask.extraGroups = [ "acme" ];

  environment.systemPackages = with pkgs; [
    vim
  ];

  services.minerva.enable = true;

  services.matterbridge = {
    enable = true;
    configPath = "/var/lib/matterbridge/config.toml";
    package = pkgs.matterbridge-ce;
  };

  virtualisation.docker.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";

  services.caddy.virtualHosts."node.smeagol.me:8080".extraConfig = ''
    reverse_proxy 192.168.1.48:8080
  '';

  services.caddy.virtualHosts."home.smeagol.me".extraConfig = ''
    reverse_proxy 10.0.0.195:8123
  '';

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

    # http3-ytproxy.enable = true;
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
      hash = "sha256-biQdtiscdmrwP6VUsuXmZrvcdewl+g50kdmab5lhE0s=";
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
    8080
    7654
  ];
  networking.firewall.allowedUDPPorts = [
    7654
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
}
