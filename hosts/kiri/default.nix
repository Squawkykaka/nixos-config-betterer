{
  config,
  pkgs,
  self,
  ...
}:
{
  imports = [
    "${self.sources.disko}/module.nix"
    ../../disks/btrfs-disk.nix
    {
      _module.args = {
        disk = "/dev/nvme0n1";
        withSwap = false;
      };
    }
  ];

  sops.secrets = {
    "cloudflare/api_token" = { };
    "bingbong/private_key" = { };
  };

  sops.templates."caddy-env" = {
    content = ''
      CF_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
      CLOUDFLARE_EMAIL=${config.sops.placeholder."email"}
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
    '';
  };

  services.caddy = {
    enable = true;
    openFirewall = true;
    package = pkgs.caddy.withPlugins {
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.2.2"
      ];
      hash = "sha256-7g8zDx5RhbptXFyEPtexxkHX8hw/gF001bZ7wX4Mjhs=";
    };

    globalConfig = ''
      acme_dns cloudflare {env.CF_API_TOKEN}
    '';

    virtualHosts."5etools.boom.boats".extraConfig = ''
      root ${pkgs."5etools"}
      file_server
    '';
    virtualHosts."panel.boom.boats".extraConfig = ''
      reverse_proxy 127.0.0.1:7887
    '';
    virtualHosts."node.boom.boats:8080".extraConfig = ''
      reverse_proxy 127.0.0.1:8089
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.sops.templates."caddy-env".path
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.nameservers = [
    "192.168.1.254"
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

  networking.firewall.allowedTCPPorts = [
    22
    2022
    8080
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 20000;
      to = 20100;
    }
  ];

  virtualisation.docker.enable = true;
  services.elytra.enable = true;

  system.stateVersion = "26.05";
}
