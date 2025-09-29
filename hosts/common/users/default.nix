# User config applicable to both nixos and darwin
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config) hostSpec;
in
  {
    imports = [
      # Allow simple alias to set/get attributes of this node
      (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" hostSpec.username])
    ];

    users.mutableUsers = false;
    users.users.${hostSpec.username} = {
      name = hostSpec.username;
      isNormalUser = true;
      shell = pkgs.nushell; # default shell
      hashedPasswordFile = config.sops.secrets."users/${config.hostSpec.username}/password".path;
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirt"
        "docker"
      ];
    };

    # Create ssh sockets directory for controlpaths when homemanager not loaded (i.e. isMinimal)
    systemd.tmpfiles.rules = let
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
        inherit pkgs inputs;
        inherit (config) hostSpec;
      };
      users.${hostSpec.username}.imports = lib.flatten [
        (
          {config, ...}:
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
