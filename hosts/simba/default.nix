##############################################################
#
#  Simba - Main Desktop
#  NixOS running on Ryzen 5 7600X, Nvidia RTX 3060Ti, 32GB RAM
#
###############################################################
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
        withSwap = true;
        swapSize = "38";
      };
    }
  ];

  services.kanata.enable = true;
  services.desktopManager.plasma6.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.supportedFilesystems = [
    "nfs"
    "ntfs"
  ];
  users.groups.media = {
    gid = 984;
  };
  users.users.gleask.extraGroups = [ "media" ];
  fileSystems."/mnt/media" = {
    device = "192.168.1.44:/volume1/linux-isos";
    fsType = "nfs";

    options = [
      "rw"
      "sec=sys"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "noatime"
      "soft"
      "_netdev"
    ];

    neededForBoot = false;
  };

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  networking = {
    networkmanager.enable = true;
  };

  # set the boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  services.flatpak.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = false;
        enableOffloadCmd = false;
      };
      sync.enable = true;
      # Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:54:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.systemPackages = [
    pkgs.freecad
    pkgs.dualsensectl
    pkgs.pinentry-gnome3
    pkgs.bottles
    pkgs.idescriptor
  ];
  services.udev.packages = [ pkgs.idescriptor ];

  system.stateVersion = "24.11";
}
