{
  networking.firewall.allowedTCPPorts = [ 8080 ];
  services.caddy.virtualHosts."node.smeagol.me:8080".extraConfig = ''
    reverse_proxy 192.168.1.48:8080
  '';
}
