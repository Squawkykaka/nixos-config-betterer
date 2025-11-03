{
  pkgs,
  config,
  ...
}: let
  serverIp = "127.0.0.1:8765";
  vpnAddress = ["10.25.33.2/32"];
  pubKey = "MOR/0/aBD1s54aTH+iwRBGfVpKiS5pOKeA2OCQMNNTk=";
in {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = vpnAddress;

      privateKeyFile = config.sops.secrets."simba/wireguard/privkey".path;

      dns = ["10.0.0.1"];

      peers = [
        {
          publicKey = pubKey;

          # Generated with https://www.procustodibus.com/blog/2021/03/wireguard-allowedips-calculator/
          allowedIPs = [
            "0.0.0.0/2"
            "64.0.0.0/3"
            "96.0.0.0/4"
            "112.0.0.0/5"
            "120.0.0.0/6"
            "124.0.0.0/7"
            "126.0.0.0/8"
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
          ];

          endpoint = serverIp;

          persistentKeepalive = 25;
        }
      ];
    };
  };

  sops.secrets.ckclient-json = {
    sopsFile = ../../../secrets/sabaton-ckclient.json;
    format = "json";
    key = "";
    owner = "ckclient";
    group = "ckclient";
    mode = "0400";
  };

  users.groups.ckclient = {};
  users.users.ckclient = {
    isSystemUser = true;
    description = "Cloak CK Client user";
    home = "/var/lib/ckclient";
    group = "ckclient";
    createHome = true;
    shell = pkgs.bash;
  };

  systemd.services.ckclient = {
    description = "Cloak CK Client";
    after = ["network.target"];
    wants = ["network.target"];

    serviceConfig = {
      User = "ckclient";
      Group = "ckclient";
      Restart = "on-failure";

      RestartSec = "2s";

      ExecStart = "${pkgs.cloak-pt}/bin/ck-client -s 203.211.120.109 -l 8765 -u -c ${
        config.sops.secrets."ckclient-json".path
      }";
    };

    wantedBy = ["multi-user.target"];
  };

  environment.systemPackages = [
    pkgs.wireguard-tools
    pkgs.cloak-pt
  ];
}
