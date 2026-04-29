{
  services.caddy.globalConfig = "order webdav before file_server";
  systemd.tmpfiles.rules = [ "d /var/lib/joplin 755 caddy caddy" ];
  services.caddy.virtualHosts."webdav.smeagol.me".extraConfig = ''
      @get method GET HEAD

      root /var/lib/joplin
      route {
        basic_auth {
          gleask $2y$12$WYMp7aRmkeDzTsvT1AXB8OIP1WXfwVRZ3kULYfMb9H6Vbzf6sGUNS
        }
        file_server @get browse
        webdav
      }
    '';
}
