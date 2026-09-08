##############################################################
#
#  Sabaton - Thinkpad X1 Extreme Gen 2
#  NixOS running on Intel Core i7, Nvidia GTX 1650 Mobile, 16GB RAM
#
###############################################################
{
  self,
  pkgs,
  ...
}:
{
  imports = [
    "${self.sources.disko}/module.nix"
    ../../disks/btrfs-disk-luks.nix
  ];

  boot.zswap = {
    enable = true;
    compressor = "lz4";
  };

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable TPM emulation (optional)
  # install pkgs.swtpm system-wide for use in virt-manager (optional)
  # Enable USB redirection (optional)
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.groups.media = {
    gid = 984;
  };
  users.users.gleask.extraGroups = [
    "kvm"
    "media"
    "libvirtd"
    "wireshark"
  ];

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gleask";
  };

  # make sure my touchpad works when typing
  services.libinput.enable = true;
  services.libinput = {
    touchpad.disableWhileTyping = true;
  };

  networking.networkmanager.enable = true;

  # set the boot loader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

  # enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "24.11";
}
