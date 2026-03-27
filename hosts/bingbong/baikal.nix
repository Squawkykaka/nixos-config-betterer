{
  pkgs,
  config,
  ...
}:
{
  services.baikal.enable = true;
  services.caddy.virtualHosts."baikal.smeagol.me".extraConfig = ''
    root * ${pkgs.baikal}/share/php/baikal/html
    encode zstd gzip

    file_server

    @caldav path /.well-known/caldav
    redir @caldav /dav.php 302

    @carddav path /.well-known/carddav
    redir @carddav /dav.php 302

    @forbidden {
        path_regexp forbidden ^/(\.ht|Core|Specific|config)
    }
    respond @forbidden 404

    php_fastcgi unix/${config.services.phpfpm.pools.${config.services.baikal.pool}.socket}
  '';
}
