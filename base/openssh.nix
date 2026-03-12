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

  security.sudo.wheelNeedsPassword = false;

  programs.ssh.startAgent = true;
  programs.ssh.extraConfig = ''
    Host bandier
      Hostname 159.13.63.123
      Port 22
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
}
