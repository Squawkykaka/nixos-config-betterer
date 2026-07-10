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

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      swtpm.enable = true;
    };
  };

  # Enable USB redirection (optional)
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  users.users.gleask.extraGroups = [
    "kvm"
    "libvirtd"
  ];

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

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaSettings = true;
  };

  services.flatpak.enable = true;

  system.stateVersion = "24.11";
}
