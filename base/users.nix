# User config applicable to both nixos and darwin
{
  inputs,
  pkgs,
  config,
  lib,
  self,
  wrappers,
  hostVars,
  ...
}:
let
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in
{
  users.mutableUsers = false;
  users.users.gleask = {
    name = "gleask";
    isNormalUser = true;
    shell = wrappers.nushell.drv; # default shell
    hashedPasswordFile = config.sops.secrets."users/gleask/password".path;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # Create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isMinimal)
  systemd.tmpfiles.rules =
    let
      user = config.users.users.gleask.name;

      inherit (config.users.users.gleask) group;
    in
    # you must set the rule for .ssh separately first, otherwise it will be automatically created as root:root and .ssh/sockects will fail
    [
      "d /home/gleask}/.ssh 0750 ${user} ${group} -"
      "d /home/gleask}/.ssh/sockets 0750 ${user} ${group} -"
    ];
}
