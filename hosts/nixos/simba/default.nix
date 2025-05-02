##############################################################
#
#  Simba - Main Desktop
#  NixOS running on Ryzen 5 7600X, Nvidia RTX 3060Ti, 32GB RAM
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
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.disko.nixosModules.disko

    #
    # ========== Disk Layout ==========
    # TODO

    #
    # ========== Misc Inputs ==========
    #
    (map lib.custom.relativeToRoot [
      #
      # ========== Required Configs ==========
      #
      "hosts/common/core"

      #
      # ========== Optional Configs ==========
      #
      "hosts/common/optional/services/bluetooth.nix"
      "hosts/common/optional/gaming.nix"
      "hosts/common/optional/hyprland.nix"
      "hosts/common/optional/solaar.nix"
      "hosts/common/optional/audio.nix"
      "hosts/common/optional/nvtop.nix"
      "hosts/common/optional/stylix.nix"
      # TODO
    ])
  ];

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  hostSpec = {
    hostName = "simba";
    username = "gleask";
    persistFolder = "/persist";
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  # set the boot loader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/"; # ← use the same mount point here.
    };
    grub = {
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
      useOSProber = true;
    };
  };

  # enable graphics
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "570.133.07";
      sha256_64bit = "sha256-LUPmTFgb5e9VTemIixqpADfvbUX1QoTT2dztwI3E3CY=";
      sha256_aarch64 = "sha256-2l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
      openSha256 = "sha256-9l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
      settingsSha256 = "sha256-XMk+FvTlGpMquM8aE8kgYK2PIEszUZD2+Zmj2OpYrzU=";
      persistencedSha256 = "sha256-4l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
    };
    nvidiaSettings = true;
    prime = {
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
      # Make sure to use the correct Bus ID values for your system!
      amdgpuBusId = "PCI:14:0:0"; # For AMD GPU
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  system.stateVersion = "24.11";
}
