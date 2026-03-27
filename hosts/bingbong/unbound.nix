{ pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.unbound = {
    enable = true;

    settings = {
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

        # performance
        msg-cache-size = "50m";
        rrset-cache-size = "100m";
        cache-min-ttl = "300";
        cache-max-ttl = "86400";
        cache-max-negative-ttl = "3600";
        prefetch = "yes";
        prefetch-key = "yes";

        # Privacy and security
        hide-identity = "yes";
        hide-version = "yes";
        qname-minimisation = "yes";
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        use-caps-for-id = "yes";
        val-clean-additional = "yes";
      };
      # forward-zone = [
      # {
      # name = ".";
      # forward-addr = "1.1.1.1@853#cloudflare-dns.com";
      # }
      # ];
      # remote-control.control-enable = true;
    };
  };
}
