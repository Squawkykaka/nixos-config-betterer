{ self, ... }:
{
  users.users.slidcord = {
    group = "slidcord";
    isSystemUser = true;
  };
  users.groups.slidcord = { };
  systemd.services.slidcord = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # PreStart = "mkdir -p /var/lib/slidcord";
      ExecStart = "${self.myPkgs.slidcord}/bin/slidcord --jid discord.smeagol.me --secret Supeswef673232fjsaifa --home-dir /var/lib/slidcord";
      Restart = "always";
      User = "slidcord";
      Group = "slidcord";

      WorkingDirectory = "/var/lib/slidcord";
      StateDirectory = "slidcord";
    };
  };
}
