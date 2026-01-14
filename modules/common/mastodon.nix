{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.kaka.mastodon = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the mastodon server setup.
      '';
    };
  };
  config = lib.mkIf config.kaka.mastodon.enable {
    services.opensearch.enable = true;
    services.mastodon.elasticsearch.host = "127.0.0.1";

    services.mastodon = {
      enable = true;
      localDomain = "m.smeagol.me";
      smtp.fromAddress = "noreply@m.smeagol.me";
      streamingProcesses = 3;
      trustedProxy = "127.0.0.1";
      extraConfig.SINGLE_USER_MODE = "true";
    };
    users.users.caddy.extraGroups = [ "mastodon" ];

    services.caddy = {
      enable = true;
      virtualHosts = {
        # Don't forget to change the host!
        "m.smeagol.me" = {
          extraConfig = ''
            handle_path /system/* {
                file_server * {
                    root /var/lib/mastodon/public-system
                }
            }

            handle /api/v1/streaming/* {
                reverse_proxy  unix//run/mastodon-streaming/streaming.socket
            }

            route * {
                file_server * {
                root ${pkgs.mastodon}/public
                pass_thru
                }
                reverse_proxy * unix//run/mastodon-web/web.socket
            }

            handle_errors {
                root * ${pkgs.mastodon}/public
                rewrite 500.html
                file_server
            }

            encode gzip

            header /* {
                Strict-Transport-Security "max-age=31536000;"
            }
            header /emoji/* Cache-Control "public, max-age=31536000, immutable"
            header /packs/* Cache-Control "public, max-age=31536000, immutable"
            header /system/accounts/avatars/* Cache-Control "public, max-age=31536000, immutable"
            header /system/media_attachments/files/* Cache-Control "public, max-age=31536000, immutable"
          '';
        };
      };
    };
  };
}
