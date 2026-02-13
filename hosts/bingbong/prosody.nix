{ config, ... }:
let
  domainName = "smeagol.me";
  sslCertDir = config.security.acme.certs.${domainName}.directory;
in
{
  # allow network connections
  networking.firewall = {
    allowedTCPPorts = [
      # prosody client to server
      5222
      5223

      5269
      5280
      5281
    ];
  };

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
          turn_external_host = "openrelay.metered.ca"
          turn_external_port = 80
          turn_external_user = "openrelayproject"
          turn_external_secret = "openrelayproject"
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

    extraModules = [
      "turn_external"
      "csi_simple"
    ];

    extraConfig = ''
      storage = "sql"
      sql = {
        driver = "SQLite3";
        database = "prosody.sqlite"; -- The database name to use. For SQLite3 this the database filename (relative to the data storage directory).
      }
    '';
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
    };
  };
}
