{
  services.caddy.virtualHosts."home.squawkykaka.com".extraConfig = ''
    reverse_proxy {
      to 192.168.1.168:8123
      to [2401:7000:6b82:7300:65c3:596:ac49:4768]:8123
    }
  '';
}
