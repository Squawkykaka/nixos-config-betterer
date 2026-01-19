{
  config,
  pkgs,
  lib,
  ...
}:
let

in
{
  options.kaka.stalwart-mail = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.kaka.stalwart-mail.enable {
    services.stalwart-mail = {
      enable = true;
      credentials = {
        user_admin_password = config.sops.secrets."stalwart/admin_password".path;
      };

      settings = {
        storage = {
          blob = "backblaze";
        };
        store."backblaze" = {
          compression = "lz4";
          purge.frequency = "30 5 *";

          type = "s3";
          bucket = "squawkyDataBackup";
          access-key = "%{env:STORAGE_S3_ACCESS_KEY}%";
          secret-key = "%{env:STORAGE_S3_SECRET_KEY}%";
          region = "us-east-005";
          endpoint = "https://s3.us-east-005.backblazeb2.com";
        };

        server.listener = {
          smtp = {
            bind = [ "[::]:25" ];
            protocol = "smtp";
          };
          submissions = {
            bind = [ "[::]:465" ];
            protocol = "smtp";
            tls.implicit = true;
          };
          imaptls = {
            bind = [ "[::]:993" ];
            protocol = "imap";
            tls.implicit = true;
          };
          management = {
            bind = [ "127.0.0.1:8080" ];
            protocol = "http";
          };
        };
      };
    };

    sops.secrets = {
      "stalwart/key_id" = { };
      "stalwart/application_key" = { };
      "stalwart/admin_password" = { };
    };

    sops.templates."stalwart-env" = {
      content = lib.generators.toKeyValue { } {
        STORAGE_S3_ACCESS_KEY = config.sops.placeholder."stalwart/key_id";
        STORAGE_S3_SECRET_KEY = config.sops.placeholder."stalwart/application_key";
      };
    };

    systemd.services.stalwart-mail.serviceConfig.EnvironmentFile = [
      config.sops.templates."stalwart-env".path
    ];
  };
}
