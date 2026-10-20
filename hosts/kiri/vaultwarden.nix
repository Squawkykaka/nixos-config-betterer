{ config, ... }: {
  sops.secrets."kiri/vaultwarden_password" = { };
  sops.templates."vaultwarden".content = ''
    ADMIN_TOKEN=${config.sops.placeholder."kiri/vaultwarden_password"}
  '';
  services.vaultwarden = {
    enable = true;
    domain = "vault.squawkykaka.com";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ENABLE_WEBSOCKET = true;
    };
    dbBackend = "sqlite";
    environmentFile = config.sops.templates."vaultwarden".path;
  };

  services.caddy.virtualHosts."vault.squawkykaka.com".extraConfig = ''
    import trusted_only
    reverse_proxy 127.0.0.1:8222
  '';
}
