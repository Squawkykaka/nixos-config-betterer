{
  networking.firewall = {
    allowedUDPPorts = [51820]; # Clients and peers can use the same port, see listenport
  };

  networking.wg-quick.interfaces = let
    server_ip = "203.211.120.109";
  in {
    wg0 = {
      # IP address of this machine in the *tunnel network*
      address = [
        "192.168.2.2/32"
      ];

      listenPort = 51820;

      # Path to the private key file.
      privateKeyFile = "/etc/wireguard-vpn.key";

      peers = [
        {
          publicKey = "pxmmH7HvLJmRwAFNK5bX4WdmZIx/anAWmU0preL3UFw=";
          allowedIPs = ["0.0.0.0/0"];
          endpoint = "${server_ip}:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
