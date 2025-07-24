{
  # pkgs,
  # config,
  ...
}: let
  # serverIp = "boom.boats:51820";
  # vpnAddress = ["10.25.232.2/32"];
  # pubKey = "eSSKuC1ByITL8gyedJVQd+8hZFo3Boz4huMD0fG2J1o=";
in {
  # networking.wireguard.interfaces = {
  #   wg0 = {
  #     ips = vpnAddress;

  #     listenPort = 51820;

  #     privateKeyFile = config.sops.secrets."wireguard/privkey".path;

  #     peers = [
  #       {
  #         publicKey = pubKey;

  #         allowedIPs = ["0.0.0.0/0"];

  #         endpoint = serverIp;
  #       }
  #     ];
  #   };
  # };

  networking.firewall = {
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
    '';
  };
}
