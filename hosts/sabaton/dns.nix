{
  services.dnsproxy = {
    enable = true;
    settings = {
      # Plain DNS upstream
      upstream = [
        "tls://dns.adguard.com"
        "https://dns.adguard.com/dns-query"
      ];
      listen-addrs = [ "127.0.0.1" ];
      # Plain DNS server
      listen-ports = [ 53 ];
    };
    # Additional launch flags
    flags = [ "--verbose" ];
  };
  networking = {
    nameservers = [
      "127.0.0.1"
    ];
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };
}
