{ pkgs, ... }: {
  fileSystems."/mnt/backups" = {
    device = "192.168.1.44:/volume1/linux-isos/backups";
    fsType = "nfs4";
    # only needed for backups
    options = [ "noauto" ];
  };
  services.postgresqlBackup = {
    enable = true;
    location = "/mnt/backups/postgres-kiri";
    databases = [ "vaultwarden" ];
  };
  systemd.services.postgresqlBackup = {
    unitConfig.RequiresMountsFor = "/mnt/backups";

    serviceConfig.ExecStartPre = [
      "${pkgs.util-linux}/bin/mountpoint -q /mnt/backups"
    ];
  };
}
