# Specifications For Differentiating Hosts
{
  config,
  lib,
  ...
}:
{
  options.hostSpec = {
    # Data variables that don't dictate configuration settings
    username = lib.mkOption {
      type = lib.types.str;
      description = "The username of the host";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "The hostname of the host";
    };
    email = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "The email of the user";
    };
    networking = lib.mkOption {
      default = { };
      type = lib.types.attrsOf lib.types.anything;
      description = "An attribute set of networking information";
    };
    wifi = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate if a host has wifi";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain of the host";
    };
    userFullName = lib.mkOption {
      type = lib.types.str;
      description = "The full name of the user";
    };
    handle = lib.mkOption {
      type = lib.types.str;
      description = "The handle of the user (eg: github user)";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "The home directory of the user";
      default =
        let
          user = config.hostSpec.username;
        in
        "/home/${user}";
    };
    persistFolder = lib.mkOption {
      type = lib.types.str;
      description = "The folder to persist data if impermenance is enabled";
      default = "";
    };

    # Configuration Settings
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a server host";
    };
    useNeovimTerminal = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Used to indicate a host that uses neovim for terminals";
    };
    useWindowManager = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Used to indicate a host that uses a window manager";
    };
    scaling = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Used to indicate what scaling to use. Floating point number";
    };
  };

  config = {
    assertions =
      let
        # We import these options to HM and NixOS, so need to not fail on HM
        isImpermanent =
          config ? "system" && config.system ? "impermanence" && config.system.impermanence.enable;
      in
      [
        {
          assertion = !isImpermanent || (isImpermanent && !("${config.hostSpec.persistFolder}" == ""));
          message = "config.system.impermanence.enable is true but no persistFolder path is provided";
        }
      ];
  };
}
