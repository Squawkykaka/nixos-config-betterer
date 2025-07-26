{
  pkgs,
  config,
  ...
}: let
  serverIp = "203.211.120.109:51820";
  vpnAddress = ["10.25.33.2/32"];
  pubKey = "eSSKuC1ByITL8gyedJVQd+8hZFo3Boz4huMD0fG2J1o=";
in {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = vpnAddress;

      privateKeyFile = config.sops.secrets."wireguard/privkey".path;

      peers = [
        {
          publicKey = pubKey;

          allowedIPs = ["10.0.0.0/24"];

          endpoint = serverIp;

          persistentKeepalive = 25;
        }
      ];
    };
  };

  environment.systemPackages = [pkgs.wireguard-tools];
}
