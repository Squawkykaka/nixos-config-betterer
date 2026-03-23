{ pkgs, ... }:
{
  services.caddy.virtualHosts."vault.boom.boats".extraConfig = ''
    reverse_proxy 127.0.0.1:8222
  '';
  services.vaultwarden = {
    enable = true;
    config = {
      DOMAIN = "https://vault.boom.boats";
      SIGNUPS_ALLOWED = false;

      # Vaultwarden recommends running behind a reverse proxy, the configureNginx option can be used for that.
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      ROCKET_LOG = "critical";

      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      # SMTP_HOST = "127.0.0.1";
      # SMTP_PORT = 25;
      # SMTP_SSL = false;

      # SMTP_FROM = "admin@bitwarden.example.com";
      # SMTP_FROM_NAME = "example.com Bitwarden server";
    };

    domain = "vault.boom.boats";
    configurePostgres = true;
    # environmentFile = "/var/lib/vaultwarden.env";
  };
}
