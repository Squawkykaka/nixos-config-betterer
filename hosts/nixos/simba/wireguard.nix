{
  pkgs,
  lib,
  config,
  ...
}:
let
  vpnAddress = [ "10.25.25.2/32" ];
in
{
  sops.secrets = {
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
