{ pkgs, ... }:
{
  services.caddy.virtualHosts."idm.smeagol.me".extraConfig = ''
    reverse_proxy 127.0.0.1:5776 {
        transport http {
            tls
            tls_server_name idm.smeagol.me
        }
    }
  '';
  users.users.kanidm.extraGroups = [ "caddy" ];
  services.kanidm = {
    package = pkgs.kanidm_1_9;
    enableServer = true;
    serverSettings = {
      bindaddress = "127.0.0.1:5776";
      # db_path = "/var/lib/kanidm/kanidm.db";
      tls_chain = "/var/lib/kanidm/chain.pem";
      tls_key = "/var/lib/kanidm/key.pem";
      domain = "idm.smeagol.me";
      origin = "https://idm.smeagol.me";
      # http_client_address_info.proxy-v1 = [ "127.0.0.1" ];
      # ldap_client_address_info.proxy-v1= [ "127.0.0.1" ];
      online_backup.versions = 3;
    };
  };
}
