{ config, ... }:
{
  sops.secrets = {
    "sabaton/private_key" = { };
  };

  services.sing-box.enable = false;
  services.sing-box.settings = {
    log = {
      disabled = false;
      level = "warn";
      timestamp = true;
    };

    dns.servers = [
      {
        type = "https";
        tag = "cloudflare";
        server = "1.1.1.1";
      }
      {
        type = "tcp";
        tag = "local";
        server = "10.0.0.1";
        detour = "wg-ep";
      }
    ];

    dns.rules = [
      {
        domain_suffix = [
          "smeagol.me"
          "boom.boats"
        ];
        server = "local";
      }
    ];
    dns.strategy = "ipv4_only";

    inbounds = [
      {
        type = "tun";
        tag = "tun-in";
        interface_name = "ipv4-tun";
        mtu = 1500;
        address = "172.19.0.1/28";
        auto_route = true;
        auto_redirect = true;
        strict_route = true;
      }
    ];
    endpoints = [
      {
        type = "wireguard";
        tag = "wg-ep";
        name = "wg0";
        private_key._secret = config.sops.secrets."sabaton/private_key".path;
        address = [ "192.168.2.3/32" ];
        peers = [
          {
            address = "203.211.121.234";
            port = 41654;
            public_key = "mKnXJRvRByS+CqIHJIg056fjDjVfxzqFYRFi4rQIShc=";
            allowed_ips = [ "0.0.0.0/0" ];
          }
        ];
      }
    ];

    outbounds = [
      {
        type = "selector";
        tag = "select";
        outbounds = [ "wg-ep" ];
        default = "wg-ep";
      }
      {
        type = "direct";
        tag = "direct-out";
      }
    ];
    route = {
      rules = [
        {
          protocol = "dns";
          action = "hijack-dns";
        }
      ];
      auto_detect_interface = true;
      default_domain_resolver = "cloudflare";
    };
  };

}
