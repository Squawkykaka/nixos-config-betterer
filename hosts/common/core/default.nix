{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = lib.flatten [
    inputs.home-manager.nixosModules.home-manager

    (map lib.custom.relativeToRoot [
      "modules/common"
      "hosts/common/users"
    ])
  ];

  #
  # ========== Core Host Specifications ==========
  #

  hostSpec = {
    username = "gleask";
    handle = "squawkykaka";
  };

  networking.hostName = config.hostSpec.hostName;

  environment.systemPackages = [ pkgs.openssh ];

  # make home-manager backup files.
  home-manager.backupFileExtension = "bk";

  #
  # ========== Overlays ==========
  #

  nixpkgs = {
    # overlays = [
    #   outputs.overlays.default
    # ];
    config = {
      allowUnfree = true;
    };
  };

  #
  # ========== Nix Nix Nix ==========
  #
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = [ "@wheel" ];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;

      allow-import-from-derivation = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
