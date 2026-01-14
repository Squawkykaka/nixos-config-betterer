# User config applicable to both nixos and darwin
{
  inputs,
  pkgs,
  config,
  lib,
  self,
  wrappers,
  ...
}:
let
  inherit (config) hostSpec;
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in
{
  users.mutableUsers = false;
  users.users.${hostSpec.username} = {
    name = hostSpec.username;
    isNormalUser = true;
    shell = wrappers.nushell.drv; # default shell
    hashedPasswordFile = config.sops.secrets."users/${config.hostSpec.username}/password".path;
    # initialHashedPassword = "$6$ZOTGb9wnuJIyq5j1$UfS9gJ.hR3Fq9SQVUuoI/U51v2tUCAhGI25W1cI8M9jjxw/b0oha5dMrdEZGWj.yKjYo7I4R31Jb0oJr5UuYf0";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirt"
      "docker"
    ];

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # Create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isMinimal)
  systemd.tmpfiles.rules =
    let
      user = config.users.users.${hostSpec.username}.name;

      inherit (config.users.users.${hostSpec.username}) group;
    in
    # you must set the rule for .ssh separately first, otherwise it will be automatically created as root:root and .ssh/sockects will fail
    [
      "d /home/${hostSpec.username}/.ssh 0750 ${user} ${group} -"
      "d /home/${hostSpec.username}/.ssh/sockets 0750 ${user} ${group} -"
    ];

  # No matter what environment we are in we want these tools
  programs.zsh.enable = true;
  environment.systemPackages = [
    pkgs.just
    pkgs.rsync
  ];
}
# Import the user's personal/home configurations, unless the environment is minimal
// {
  home-manager = {
    extraSpecialArgs = {
      inherit
        pkgs
        inputs
        self
        wrappers
        ;
      inherit (config) hostSpec;
    };
    users.${hostSpec.username}.imports = lib.flatten [
      (
        { config, ... }:
        import (lib.custom.relativeToRoot "home/${hostSpec.hostName}.nix") {
          inherit
            pkgs
            inputs
            config
            lib
            hostSpec
            ;
        }
      )
    ];
  };
}
