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
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.self}/disks/btrfs-disk-luks.nix"
  ];

  virtualisation.docker.enable = true;

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
