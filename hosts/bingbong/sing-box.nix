{ config, ... }:
let
  sslCertDir = config.security.acme.certs."boom.boats".directory;
in
{
  networking.firewall.allowedTCPPorts = [
    9760
  ];
  networking.firewall.allowedUDPPorts = [
    9760
  ];

  services.sing-box.enable = true;
  services.sing-box.settings = {
    log = {
      disabled = false;
      level = "warn";
      timestamp = true;
    };

    dns.servers = [
      {
        type = "local";
        tag = "local";
      }
    ];

    outbounds = [
      {
        tag = "direct-out";
        type = "direct";
      }
    ];

    inbounds = [
      # maybe setup in oracle vps
      {
        type = "vless";
        tag = "vless-in";
        listen = "::";
        listen_port = 9760;
        users = [
          {
            uuid = {
              _secret = config.sops.secrets."sing_box/uuid".path;
            };
            flow = "xtls-rprx-vision";
          }
        ];

        tls = {
          enabled = true;
          server_name = "apple.com";
          reality = {
            enabled = true;
            handshake = {
              server = "apple.com";
              server_port = 443;
              domain_resolver = {
                server = "local";
                # might do ipv6 in future
                strategy = "ipv4_only";
              };
            };

            private_key = {
              _secret = config.sops.secrets."sing_box/private_key".path;
            };

            short_id = {
              _secret = config.sops.secrets."sing_box/short_id".path;
            };
          };
        };
      }
    ];
  };

  sops.secrets = {
    "sing_box/private_key" = { };
    "sing_box/short_id" = { };
    "sing_box/uuid" = { };
  };
}
