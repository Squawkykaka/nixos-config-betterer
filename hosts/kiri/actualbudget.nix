{ pkgs, ... }: {
  services.actual = {
    enable = true;
    package = pkgs.actual-server.overrideAttrs (old: {
      version = "26.10.0";
      src = old.src.overrideAttrs {
        version = "26.10.0";
        hash = "sha256-jBh6mrYVVX7dNz5rv/VO766ezIuwBmXbtRSKgUOkahc=";
      };
    });
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
