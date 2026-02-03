{
  pkgs,
  lib,
  config,
  ...
}:
let
  vpnAddress = [ "10.25.25.3/32" ];
in
{
  sops.secrets = {
    "sabaton/private_key" = { };
    "simba/private_key" = { };
  };

  users.users.wstunnel = {
    isSystemUser = true;
    group = "wstunnel";
  };
  users.groups.wstunnel = { };

  sops.secrets = {
    "wstunnel_secret" = { };
  };

  sops.templates."wstunnel-env" = {
    content = lib.generators.toKeyValue { } {
      WSTUNNEL_HTTP_UPGRADE_PATH_PREFIX = config.sops.placeholder."wstunnel_secret";
    };
  };

  systemd.services.wstunnel = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.wstunnel}/bin/wstunnel client -L 'udp://51821:localhost:51820?timeout_sec=0' wss://203.211.120.109:9800";
      Restart = "always";
      EnvironmentFile = config.sops.templates."wstunnel-env".path;
      User = "wstunnel";
      Group = "wstunnel";
    };
  };

  networking.wg-quick.interfaces = {
    wg0 = {
      address = vpnAddress;

      privateKeyFile = config.sops.secrets."simba/private_key".path;

      listenPort = 51820;

      dns = [ "10.0.0.1" ];

      mtu = 1400;

      peers = [
        {
          publicKey = "QhkTigyEq1EFnQKG9fH0f29OCoecybIveairBUyGPBU=";

          allowedIPs = [
            "10.25.25.1/32"
            "0.0.0.0/1"
            "128.0.0.0/2"
            "192.0.0.0/5"
            "200.0.0.0/7"
            "202.0.0.0/8"
            "203.0.0.0/9"
            "203.128.0.0/10"
            "203.192.0.0/12"
            "203.208.0.0/15"
            "203.210.0.0/16"
            "203.211.0.0/18"
            "203.211.64.0/19"
            "203.211.96.0/20"
            "203.211.112.0/21"
            "203.211.120.0/26"
            "203.211.120.64/27"
            "203.211.120.96/29"
            "203.211.120.104/30"
            "203.211.120.108/32"
            "203.211.120.110/31"
            "203.211.120.112/28"
            "203.211.120.128/25"
            "203.211.121.0/24"
            "203.211.122.0/23"
            "203.211.124.0/22"
            "203.211.128.0/17"
            "203.212.0.0/14"
            "203.216.0.0/13"
            "203.224.0.0/11"
            "204.0.0.0/6"
            "208.0.0.0/4"
            "224.0.0.0/3"
            "::/0"
            # "10.0.0.0/24"
            # modify to exclude home ip
            # "0.0.0.0/0"
          ];

          endpoint = "127.0.0.1:51821";

          persistentKeepalive = 20;
        }
      ];
    };
  };

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
