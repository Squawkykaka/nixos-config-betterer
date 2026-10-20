{
  services.actual = {
    enable = true;
    settings = {
      port = 9007;
      hostname = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."actual.squawkykaka.com".extraConfig = ''
    encode gzip zstd
    reverse_proxy 127.0.0.1:9007
  '';
}
