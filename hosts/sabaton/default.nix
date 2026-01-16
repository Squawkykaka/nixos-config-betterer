##############################################################
#
#  Sabaton - Thinkpad X1 Extreme Gen 2
#  NixOS running on Intel Core i7, Nvidia GTX 1650 Mobile, 16GB RAM
#
###############################################################
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = lib.flatten [
    #
    # ========== Hardware ==========
    #

    ./hardware-configuration.nix
    # inputs.hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
    inputs.disko.nixosModules.disko

    (map lib.custom.relativeToRoot [
      #
      # ========== Required Configs ==========
      #
      "hosts/common/core"
      "hosts/common/disks/btrfs-disk-luks.nix"
      #
      # ========== Optional Configs ==========
      #
      "hosts/common/optional/services/bluetooth.nix"
      "hosts/common/optional/services/gpg.nix"
      "hosts/common/optional/services/sddm.nix"
      "hosts/common/optional/gaming.nix"
      # "hosts/common/optional/solaar.nix"
      "hosts/common/optional/audio.nix"
      "hosts/common/optional/syncthing.nix"
    ])
  ];

  hostSpec = {
    hostName = "sabaton";
    username = "gleask";
    persistFolder = "/persist";
  };

  services.openssh.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "gleask";
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
