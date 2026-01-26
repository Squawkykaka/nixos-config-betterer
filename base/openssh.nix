{
  services.openssh = {
    enable = true;
    ports = [ 22 ];

    settings = {
      # Harden
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Automatically remove stale sockets
      StreamLocalBindUnlink = "yes";
      # Allow forwarding ports to everywhere
      GatewayPorts = "clientspecified";
    };
  };

  programs.ssh.startAgent = true;

  networking.firewall.allowedTCPPorts = [ 22 ];
}
