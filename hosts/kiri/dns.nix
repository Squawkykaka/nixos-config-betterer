{
  services.technitium-dns-server = {
    enable = true;
  };
  networking.firewall.allowedUDPPorts = [ 53 853 ];

  services.caddy.virtualHosts."dns.boom.boats".extraConfig = ''
    reverse_proxy 127.0.0.1:8053
  '';

  services.caddy.virtualHosts."technitium.boom.boats".extraConfig = ''
    reverse_proxy 127.0.0.1:5380
  '';
}
