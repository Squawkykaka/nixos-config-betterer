{ lib, ... }:
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
      X11Forwarding = false;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  programs.ssh.startAgent = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;
  programs.ssh.extraConfig = ''
    Host bandier
      Hostname 159.13.63.123
      Port 22
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];
}
