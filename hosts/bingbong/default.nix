{
  lib,
  pkgs,
  config,
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "25.11";

  services.caddy.virtualHosts."node.smeagol.me:8080".extraConfig = ''
    reverse_proxy 192.168.1.48:8080
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

  sops.secrets = {
    "cloudflare/api_token" = { };
    "bingbong/private_key" = { };
  };

  sops.templates."caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      CLOUDFLARE_EMAIL=${config.sops.placeholder."email"}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
    '';
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.2"
        "github.com/mholt/caddy-webdav@v0.0.0-20260127042217-fa2f366b0d75"
      ];
      hash = "sha256-cbIn2gYXJS2CSOh6xgN3lk8MPUmt0GSlOae1MLADYxg=";
    };

    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.sops.templates."caddy-env".path
  ];

  networking.firewall.enable = true;

  security.acme.defaults.email = "contact@squawkykaka.com";
  security.acme.defaults.environmentFile = config.sops.templates."matrix-caddy-env".path;
  security.acme.defaults.dnsProvider = "cloudflare";
  security.acme.acceptTerms = true;

  kaka.servarr.enable = false;
}
