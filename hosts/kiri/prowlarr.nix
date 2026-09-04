{
  services.prowlarr.enable = true;
  services.caddy.virtualHosts."prowlarr.squawkykaka.com".extraConfig = ''
    reverse_proxy 127.0.0.1:9696
  '';
}
