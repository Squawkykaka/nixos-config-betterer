{ pkgs, ... }: {
  environment.etc."numa/numa.toml".source = pkgs.writers.writeTOML "numa.toml" {
    upstream.mode = "recursive";
    dnssec.enabled = true;
    dnssec.strict = true;

    lan.enabled = true;
  };

  users.groups.numa = { };
  users.users.numa = {
    isSystemUser = true;
    group = "numa";
  };
  systemd.services.numa = {
    description = "Portable DNS resolver in Rust — .numa local domains, ad blocking, developer overrides";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      User = "numa";
      Group = "numa";
      StateDirectory = "numa";
      LogDirectory = "numa";
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${pkgs.numa}/bin/numa /etc/numa/numa.toml";

      AmbientCapabilities = "CAP_NET_BIND_SERVICE";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
    };
  };
}
