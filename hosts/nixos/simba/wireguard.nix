{
  pkgs,
  config,
  ...
}:
let
  serverIp = "127.0.0.1:4567";
  vpnAddress = [ "10.25.25.2/32" ];
  pubKey = "QhkTigyEq1EFnQKG9fH0f29OCoecybIveairBUyGPBU=";
in
{
  sops.secrets = {
    "simba/private_key" = { };
  };
  networking.wg-quick.interfaces = {
    wg0 = {
      address = vpnAddress;

      privateKeyFile = config.sops.secrets."simba/private_key".path;

      listenPort = 51820;

      dns = [ "10.0.0.1" ];

      mtu = 1350;

      peers = [
        {
          publicKey = pubKey;

          allowedIPs = [
            "10.25.25.1/32"
            # "10.0.0.0/24"
            # modify to exclude home ip
            # "0.0.0.0/0"
          ];

          endpoint = serverIp;

          persistentKeepalive = 25;
        }
      ];
    };
  };

  environment.systemPackages = [ pkgs.wireguard-tools ];
}
