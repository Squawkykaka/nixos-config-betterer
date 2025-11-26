{
  lib,
  modulesPath,
  pkgs,
  lib,
  config,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      (modulesPath + "/profiles/qemu-guest.nix")
    ]
    ++ (map lib.custom.relativeToRoot [
      "hosts/common/core"
    ]);

  hostSpec = {
    hostName = "bingbong";
    username = "gleask";
    persistFolder = "/persist";
  };

  services.cloud-init.network.enable = true;

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.grub.devices = ["nodev"];
  boot.growPartition = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  programs.ssh.startAgent = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";

  sops.secrets = {
    "synapse/registration_secret" = {};
    "synapse/turn_auth_secret" = {};
  };

  sops.templates."synapse-config".content = lib.generators.toYAML {} {
    registration_shared_secret = config.sops.placeholder."synapse/registration_secret";
    turn_shared_secret = config.sops.placeholder."synapse/turn_auth_secret";
  };
  sops.templates."coturn-auth-secret".content = config.sops.placeholder."synapse/turn_auth_secret";

  services.matrix-synapse = {
    enable = true;
    configureRedisLocally = true;

    extraConfigFiles = [config.sops.templates."synapse-config".path];
    settings = {
      public_baseurl = "https://smeagol.me";
      server_name = "smeagol.me";
      enable_metrics = true;
      turn_uris = [
        "turn:turn.smeagol.me:3487?transport=udp"
        "turn:turn.smeagol.me:3487?transport=tcp"
      ];
      redis.enabled = true;
    };
  };

  services.coturn = {
    enable = true;
    realm = "turn.smeagol.me";
    use-auth-secret = true;
    static-auth-secret-file = config.sops.templates."coturn-auth-secret".path;
    no-tcp-relay = true;

    extraConfig = ''
      external-ip=203.211.120.109
      listening-ip=10.0.0.76
      # enable logging
      syslog

      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255

      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff

      allowed-peer-ip=10.0.0.76

      user-quota=12
      total-quota=1200
    '';
  };
}
