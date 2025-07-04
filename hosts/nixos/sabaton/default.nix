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
    ./borg.nix
    # ./wireguard.nix
    inputs.hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
    inputs.disko.nixosModules.disko

    #
    # ========== Disk Layout ==========
    # TODO

    #
    # ========== Misc Inputs ==========
    #
    inputs.lanzaboote.nixosModules.lanzaboote
    (map lib.custom.relativeToRoot [
      #
      # ========== Required Configs ==========
      #
      "hosts/common/core"

      #
      # ========== Optional Configs ==========
      #
      "hosts/common/optional/services/bluetooth.nix"
      "hosts/common/optional/services/greetd.nix"
      "hosts/common/optional/gaming.nix"
      "hosts/common/optional/hyprland.nix"
      # "hosts/common/optional/solaar.nix"
      "hosts/common/optional/audio.nix"
      "hosts/common/optional/syncthing.nix"
      # TODO
    ])
  ];

  hostSpec = {
    hostName = "sabaton";
    username = "gleask";
    persistFolder = "/persist";
  };

  networking = {
    networkmanager.enable = true;
    enableIPv6 = false;
  };

  # make sure my touchpad works when typing
  services.libinput.enable = true;
  services.libinput = {
    touchpad.disableWhileTyping = true;
  };

  # set the boot loader
  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  };

  # enable graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "570.133.07";
    #   sha256_64bit = "sha256-LUPmTFgb5e9VTemIixqpADfvbUX1QoTT2dztwI3E3CY=";
    #   sha256_aarch64 = "sha256-2l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
    #   openSha256 = "sha256-9l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
    #   settingsSha256 = "sha256-XMk+FvTlGpMquM8aE8kgYK2PIEszUZD2+Zmj2OpYrzU=";
    #   persistencedSha256 = "sha256-4l8N83Spj0MccA8+8R1uqiXBS0Ag4JrLPjrU3TaXHnM=";
    # };
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:0:2:0"; # For Intel GPU
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # make sure sbctl is enabled for this machine
  environment.systemPackages = [
    pkgs.sbctl
    pkgs.timeshift
  ];

  # enable auto-cpu freq, disable power profiles as it interferes
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.tlp.enable = true;

  system.stateVersion = "24.11";
}
