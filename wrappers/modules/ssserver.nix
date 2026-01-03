{ adios }:
let
  inherit (adios) types;
in
{
  name = "ssserver";

  inputs.nixpkgs.path = "/nixpkgs";

  options = {
    package = {
      type = types.derivation;
      defaultFunc =
        { inputs }:
        let
          inherit (inputs.nixpkgs) pkgs;
        in
        pkgs.shadowsocks-rust;
    };
    client-settings = {
      type = types.attrs;
      default = {
        server = "10.0.0.8";
        server_port = 7654;
        local_port = 4567;
        password = "\${PASSWORD_ENV}";
        timeout = 300;
        method = "chacha20-ietf-poly1305";
        mode = "udp_only";
        tunnel_address = "127.0.0.1:51820";
        # plugin = "v2ray-plugin";
        # plugin_opts = "mode=quic;host=github.com";
        # plugin_mode = "tcp_and_udp";
      };
    };
    server-settings = {
      type = types.attrs;
      default = {
        server = "127.0.0.1";
        server_port = 7654;
        password = "\${PASSWORD_ENV}";
        timeout = 300;
        method = "chacha20-ietf-poly1305";
        mode = "udp_only";
        # plugin = "v2ray-plugin";
        # plugin_opts = "mode=quic;host=github.com";
        # plugin_mode = "tcp_and_udp";
      };
    };
  };

  impl =
    {
      options,
      inputs,
    }:
    let
      inherit (inputs.nixpkgs) pkgs lib;
      inherit (pkgs)
        symlinkJoin
        makeWrapper
        writeText
        linkFarm
        ;
    in
    symlinkJoin {
      name = "ssserver-wrapped";
      paths = [
        options.package
        # pkgs.shadowsocks-v2ray-plugin
        (linkFarm "ssserver-config" [
          {
            name = "server-config.json";
            path = writeText "server-config.json" (builtins.toJSON options.server-settings);
          }
          {
            name = "client-config.json";
            path = writeText "client-config.json" (builtins.toJSON options.client-settings);
          }
        ])
      ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/ssserver \
          --add-flags "-c $out/server-config.json"
        wrapProgram $out/bin/sslocal \
          --add-flags "-c $out/client-config.json"
      '';
      meta.mainProgram = "ssserver";
    };
}
