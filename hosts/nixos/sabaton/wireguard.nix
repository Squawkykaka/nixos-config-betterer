{
  # pkgs,
  config,
}: let
  serverIp = "boom.boats:51820";
  vpnAddress = ["10.25.232.2/32"];
  pubKey = "eSSKuC1ByITL8gyedJVQd+8hZFo3Boz4huMD0fG2J1o=";
in {
  networking.wireguard.interfaces = {
    wg0 = {
      ips = vpnAddress;

      listenPort = 51820;

      privateKeyFile = config.sops.secrets."wireguard/privkey".path;

      peers = [
        {
          publicKey = pubKey;

          allowedIPs = ["0.0.0.0/0"];

          endpoint = "${serverIp}:51820";
        }
      ];
    };
  };
}
