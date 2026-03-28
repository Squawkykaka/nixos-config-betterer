{
  config,
  pkgs,
  self,
  ...
}:
{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD"; # this is important!
    fsType = "ext4";
    options = [ "noatime" ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "26.05";
}
