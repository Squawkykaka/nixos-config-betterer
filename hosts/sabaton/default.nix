##############################################################
#
#  Sabaton - Thinkpad X1 Extreme Gen 2
#  NixOS running on Intel Core i7, Nvidia GTX 1650 Mobile, 16GB RAM
#
###############################################################
{
  pkgs,
  self,
  ...
}:
{
  imports = [
    "${self.sources.disko}/module.nix"
    ../../disks/btrfs-disk-luks.nix
  ];

  zramSwap = {
    enable = true;
    priority = 100;
    algorithm = "lz4";
    memoryPercent = 50;
  };

  environment.systemPackages = [
    pkgs.kicad
    pkgs.wine64Packages.waylandFull
  ];
  virtualisation.libvirtd.enable = true;

  # Enable TPM emulation (optional)
  # install pkgs.swtpm system-wide for use in virt-manager (optional)
  virtualisation.libvirtd.qemu = {
    swtpm.enable = true;
  };

  # Enable USB redirection (optional)
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  programs.wireshark.enable = true;
  programs.wireshark.dumpcap.enable = true;
  programs.wireshark.usbmon.enable = true;

  users.groups.media = {
    gid = 984;
  };
  users.users.gleask.extraGroups = [
    "media"
    "libvirtd"
  ];
  boot.supportedFilesystems = [
    "nfs"
    "ntfs"
  ];

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gleask";
    defaultSession = "mango";
  };

  networking.networkmanager.enable = true;

  # make sure my touchpad works when typing
  services.libinput.enable = true;
  services.libinput = {
    touchpad.disableWhileTyping = true;
  };

  # set the boot loader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  # enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "24.11";
}
