{
  pkgs,
  config,
  ...
}: let
  serverIp = "127.0.0.1:8765";
  vpnAddress = ["10.25.33.2/32"];
  pubKey = "eSSKuC1ByITL8gyedJVQd+8hZFo3Boz4huMD0fG2J1o=";

  ckclientJson = pkgs.writeText "ckclient.json" (pkgs.sops-nix.decryptFile ../../../secrets/ckclient.sops.json);
in {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = vpnAddress;

      privateKeyFile = config.sops.secrets."wireguard/privkey".path;

      dns = ["10.0.0.1"];

      peers = [
        {
          publicKey = pubKey;

          allowedIPs = [
            # "10.0.0.0/24"
            "0.0.0.0/0"
          ];

          endpoint = serverIp;

          persistentKeepalive = 25;
        }
      ];
    };
  };

  users.users.ckclient = {
    isSystemUser = true;
    description = "Cloak CK Client user";
    home = "/var/lib/ckclient";
    createHome = true;
    shell = pkgs.bash;
  };

  systemd.services.ckclient = {
    description = "Cloak CK Client";
    after = ["network.target"];
    wants = ["network.target"];
    serviceConfig = {
      ExecStart = "${pkgs.ck-client}/bin/ck-client -s boom.boats -l 8765 -u ${ckclientJson}";
      Restart = "always";
      User = "ckclient";
    };
    wantedBy = ["multi-user.target"];

    preStart = ''
      ${ckclientJson}
    '';
  };

  environment.systemPackages = [pkgs.wireguard-tools pkgs.cloak-pt];
}
