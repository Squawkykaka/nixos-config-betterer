{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  systemd.timers.update-unbound-blocklist = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon 02:00:00";
      Persistent = true;
      AccuracySec = "12h";
      Unit = "update-unbound-blocklist.service";
    };
  };
  systemd.services.update-unbound-blocklist = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = [
      pkgs.bash
      pkgs.curl
      pkgs.gawk
    ];

    serviceConfig = {
      # Type = "simple";
      User = "root";
      ExecStart = "${./update-blocklist.sh}";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl reload unbound.service";
    };
  };
  services.unbound = {
    enable = true;

    settings = {
      include = [ "/etc/unbound/block.conf" ];
      server = {
        interface = [
          # "127.0.0.1"
          # "0.0.0.0"
          "10.0.0.76"
          "::1"
        ];
        access-control = [
          "10.0.0.0/8 allow"
          "192.168.0.0/16 allow"
        ];
        root-hints = "${pkgs.dns-root-data}/root.hints";

        # disable dnssec for boom.boats and smeagol.me
        domain-insecure = [
          "boom.boats."
          "smeagol.me."
        ];

        # performance
        msg-cache-size = "50m";
        rrset-cache-size = "100m";
        cache-min-ttl = "300";
        cache-max-ttl = "86400";
        cache-max-negative-ttl = "3600";
        prefetch = "yes";
        prefetch-key = "yes";
        so-reuseport = "yes";
        num-threads = 16;

        # Privacy and security
        hide-identity = "yes";
        hide-version = "yes";
        qname-minimisation = "yes";
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        use-caps-for-id = "yes";
        val-clean-additional = "yes";
      };
      # remote-control.control-enable = true;
      forward-zone = [
        {
          name = "smeagol.me.";
          forward-addr = "10.0.0.1";
        }
        {
          name = "boom.boats.";
          forward-addr = "10.0.0.1";
        }
      ];
    };
  };
}
