{ config, ... }: {
  sops.secrets."kiri/miniflux_password" = { };
  sops.templates."miniflux-env".content = ''
    ADMIN_USERNAME=gleask
    ADMIN_PASSWORD=${config.sops.placeholder."kiri/miniflux_password"}
  '';
  services.miniflux.enable = true;
  services.miniflux.config.LISTEN_ADDR = "localhost:7434";
  services.miniflux.adminCredentialsFile = config.sops.templates."miniflux-env".path;

  services.caddy.virtualHosts."rss.boom.boats".extraConfig = ''
    reverse_proxy ${config.services.miniflux.config.LISTEN_ADDR}
  '';
}
