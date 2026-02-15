{
  lib,
  pkgs,
  self,
  config,
  ...
}:
{
  networking.hostName = self.hostVars.hostname;

  environment.systemPackages = [
    pkgs.openssh
    pkgs.trashy
    pkgs.starship
    self.wrappers.nushell.drv
    pkgs.carapace
    self.wrappers.git.drv
    self.wrappers.helix.drv
  ];

  #
  # ========== Nix Nix Nix ==========
  #

  nixpkgs.config.allowUnfree = true;
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    channel.enable = false;
    nixPath = lib.mapAttrsToList (k: v: "${k}=${v}") self.sources;
    registry = lib.mapAttrs (_: path: {
      to = {
        type = "path";
        inherit path;
      };
    }) self.sources;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = [
        "root"
        "@wheel"
      ];
      # Deduplicate and optimize nix store
      warn-dirty = false;

      allow-import-from-derivation = false;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.nixos.org"
      ];

      # Public Keys
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  # Database for aiding terminal-based programs
  environment.enableAllTerminfo = true;
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  # This should be handled by config.security.pam.sshAgentAuth.enable
  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  #
  # ========== Nix Helper ==========
  #
  # Provide better build output and will also handle garbage collection in place of standard nix gc (garbace collection)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 5";
    flake = "/home/gleask/nixos";
  };

  #
  # ========== Localization ==========
  #
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "Pacific/Auckland";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
