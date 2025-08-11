{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = lib.flatten [
    inputs.home-manager.nixosModules.home-manager

    (map lib.custom.relativeToRoot [
      "modules/common"
      "hosts/common/users"
    ])

    ./stylix.nix
    ./sops.nix
  ];

  #
  # ========== Core Host Specifications ==========
  #
  hostSpec = {
    username = "gleask";
    handle = "squawkykaka";

    networking.ports.tcp.ssh = 22;
  };

  networking.hostName = config.hostSpec.hostName;

  environment.systemPackages = [pkgs.openssh pkgs.trashy pkgs.nushell pkgs.starship pkgs.carapace];

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
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # See https://jackson.dev/post/nix-reasonable-defaults/
      connect-timeout = 5;
      log-lines = 25;
      min-free = 128000000; # 128MB
      max-free = 1000000000; # 1GB

      trusted-users = ["@wheel"];
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
      warn-dirty = false;

      allow-import-from-derivation = true;

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
    sudo.extraConfig = ''
      Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
      Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
      Defaults timestamp_timeout=120 # only ask for password every 2h
      # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
      Defaults env_keep+=SSH_AUTH_SOCK
    '';

    polkit.enable = true;
    rtkit.enable = true;
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = ["graphical-session.target"];
    wants = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIBpDCCAUmgAwIBAgIQBh+vmThPEnQkiY7L73KtmjAKBggqhkjOPQQDAjAwMRIw
      EAYDVQQKEwlTcXVhd2t5Q0ExGjAYBgNVBAMTEVNxdWF3a3lDQSBSb290IENBMB4X
      DTI1MDczMTEwMzQzNloXDTM1MDcyOTEwMzQzNlowMDESMBAGA1UEChMJU3F1YXdr
      eUNBMRowGAYDVQQDExFTcXVhd2t5Q0EgUm9vdCBDQTBZMBMGByqGSM49AgEGCCqG
      SM49AwEHA0IABNSfbIgxfooq/3qJPWl6Uws+Fcs3ga+ULOtJDr+nKkNWL561uc7a
      915FwfHVSNnf4YDto8bErmRVfi4ov6PoFKCjRTBDMA4GA1UdDwEB/wQEAwIBBjAS
      BgNVHRMBAf8ECDAGAQH/AgEBMB0GA1UdDgQWBBRUanE7yI+97CnxJo1uphF6BWGU
      ejAKBggqhkjOPQQDAgNJADBGAiEA1WesJk6CjaJvAgNOcysG6h4QxilXT2EK3Nm7
      OxioeZUCIQDuVxCdGFR7L90rO9eT9SmfgsVJbmESrYfCVwzxni7ggw==
      -----END CERTIFICATE-----
    ''
  ];

  #
  # ========== Nix Helper ==========
  #
  # Provide better build output and will also handle garbage collection in place of standard nix gc (garbace collection)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 20d --keep 5";
    flake = "${config.hostSpec.home}/nixos";
  };

  users.mutableUsers = false;

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
