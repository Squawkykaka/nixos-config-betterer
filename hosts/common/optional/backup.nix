{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets = {
    "restic/key" = {};
    "restic/key_id" = {};
    "restic/password" = {};
  };

  sops.templates."restic-env".content = ''
    AWS_ACCESS_KEY_ID=${config.sops.placeholder."restic/key_id"}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."restic/key"}
  '';

  users = {
    users.restic = {
      group = "restic";
      isSystemUser = true;
    };
    groups.restic = {};
  };

  security.wrappers.restic = {
    source = lib.getExe pkgs.restic;
    owner = "restic";
    group = "restic";
    permissions = "500"; # u=rx,g=,o=
    capabilities = "cap_dac_read_search+ep";
  };

  services.restic.backups."main" = {
    user = "restic";
    package = pkgs.writeShellScriptBin "restic" ''
      exec /run/wrappers/bin/restic "$@"
    '';

    paths = [
      "/home/gleask/documents"
      "/home/gleask/media"
    ];

    exclude = [
      "**/node_modules"
      "**/.direnv"
      "**/target"
      "**/build"
      "**/.venv"
      "**/.next"
      "**/.gradle"
    ];

    repository = "s3:https://s3.us-east-005.backblazeb2.com/squawkyDataBackup";

    environmentFile = config.sops.templates."restic-env".path;
    passwordFile = config.sops.secrets."restic/password".path;
  };
}
