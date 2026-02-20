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

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.nameservers = [
    "10.0.0.1"
    "2401:7000:d900:5::3a4"
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

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
