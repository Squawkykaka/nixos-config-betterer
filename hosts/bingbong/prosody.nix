{ config, ... }:
let
  domainName = "smeagol.me";
  sslCertDir = config.security.acme.certs.${domainName}.directory;
in
{
  users.users.prosody.extraGroups = [ "acme" ];

  systemd.services.prosody-filer.serviceConfig = {
    StateDirectory = "prosody-filer";
    RuntimeDirectory = "prosody-filer";
    RuntimeDirectoryMode = "0750";
  };

  services.prosody-filer = {
    enable = true;
    settings = {
      secret = "plain in line password";
      storeDir = "/var/lib/prosody-filer/uploads/";

      # this option refers to the upload url
      # https://upload.xmpp.${domainName}/upload/
      #                                  <------->
      # do not change this, else 404
      uploadSubDir = "upload/";
    };
  };

  services.prosody = {
    enable = true;
    admins = [ "admin@smeagol.me" ];
    muc = [
      {
        domain = "muc.xmpp.${domainName}";
        restrictRoomCreation = false;
      }
    ];

    httpFileShare = {
      domain = "upload.xmpp.${domainName}";
    };

    ssl = {
      cert = "${sslCertDir}/fullchain.pem";
      key = "${sslCertDir}/key.pem";
    };

    virtualHosts = {
      main = {
        domain = domainName;
        enabled = true;
        ssl = {
          cert = "${sslCertDir}/fullchain.pem";
          key = "${sslCertDir}/key.pem";
        };
        extraConfig = ''
          turn_external_host = "turn.${domainName}"
          turn_external_secret = "aasoffaFDOSFH&8*%"
        '';
      };
      localhost = {
        domain = "localhost";
        enabled = true;
      };
    };

    modules.websocket = true;
    modules.csi = true;
    modules.bosh = true;
    modules.mam = true;

    extraModules = [
      "turn_external"
      "csi_simple"
      "muc_mam"
      "seclables"
    ];

    extraConfig = ''
      muc_log_expires_after = "1m"

      storage = "sql"
      sql = {
        driver = "SQLite3";
        database = "prosody.sqlite"; -- The database name to use. For SQLite3 this the database filename (relative to the data storage directory).
      }
    '';
  };

  services.coturn = rec {
    enable = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret = "aasoffaFDOSFH&8*%";
    realm = "turn.smeagol.me";
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  networking.firewall =
    let
      range = with config.services.coturn; [
        {
          from = min-port;
          to = max-port;
        }
      ];
    in
    {
      allowedUDPPortRanges = range;
      allowedUDPPorts = [
        5349
        3478
      ];
      allowedTCPPortRanges = range;
      allowedTCPPorts = [
        5349
        3478

        5222
        5223

        5269
        5280
        5281
      ];
    };

  security.acme = {
    acceptTerms = true;
    certs = {
      ${domainName} = {
        # webroot = "/var/www/${domainName}";
        email = "squawkykaka@gmail.com";
        extraDomainNames = [
          "muc.xmpp.${domainName}"
          "upload.xmpp.${domainName}"
        ];
      };
      ${config.services.coturn.realm} = {
        # insert here the right configuration to obtain a certificate
        postRun = "systemctl restart coturn.service";
        group = "turnserver";
      };
    };
  };
}
