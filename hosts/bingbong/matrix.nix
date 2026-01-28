{ lib, config, ... }:
{
  # matrix
  services.matrix-continuwuity = {
    enable = true;

    settings = {
      global.trusted_servers = [
        "matrix.org"
        "tchncs.de"
        "nhnn.dev"
        "zimward.moe"
        "kirottu.com"
        "unredacted.org"
        "envs.net"
        "matrix.debian.social"
        "t2bot.io"
        "maunium.net"
        "0upti.me"
        "purplg.com"
        "mtrnord.blog"
        "continuwuity.org"
        "heyadora.com"
      ];
      global.server_name = "smeagol.me";
    };
  };
  # systemd.services.continuwuity.serviceConfig.StateDirectory = lib.mkForce "";

  services.caddy.virtualHosts."smeagol.me".extraConfig =
    let
      toJSON = lib.generators.toJSON { };
    in
    ''
      handle /.well-known/matrix/server {
        header Content-Type application/json
        header access-control-allow-origin *

        respond ${
          toJSON {
            "m.server" = "matrix.smeagol.me:443";
          }
        }
      }

      handle /.well-known/matrix/client {
        header Content-Type application/json
        header access-control-allow-origin *

        respond ${
          toJSON {
            "m.homeserver".base_url = "https://matrix.smeagol.me";
          }
        }
      }

      handle /* {
        respond "OI THIS AINT NUFFIN, PISS OFF"
      }
    '';

  services.caddy.virtualHosts."matrix.smeagol.me".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString (builtins.elemAt config.services.matrix-continuwuity.settings.global.port 0)}
  '';
}
