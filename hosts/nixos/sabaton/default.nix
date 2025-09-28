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
}: {
  imports = lib.flatten [
    #
    # ========== Hardware ==========
    #

    ./hardware-configuration.nix
    ./borg.nix
    ./wireguard.nix
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
      "hosts/common/optional/services/gpg.nix"
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
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

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
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = ["nvidia"];
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
    pkgs.openvpn
    # pkgs.networkmanager
    # pkgs.networkmanager-openvpn
  ];

  services.stunnel = {
    enable = true;

    # Run stunnel as root (or another user if you prefer)
    user = "root";
    group = "root";

    # Increase verbosity for debugging
    logLevel = "info";

    # Define client connections
    clients = {
      openvpn = {
        accept = "127.0.0.1:1194"; # Local port your OpenVPN client connects to
        connect = "boom.boats:443"; # Your UDM SE public IP and port
        client = true; # Must be client mode
        cert = "/home/gleask/.certs/client.crt";
        key = "/home/gleask/.certs/client.key";

        CAFile = toString (pkgs.writeText "stunnel-key.crt" ''
          -----BEGIN CERTIFICATE-----
          MIIDvzCCAqegAwIBAgIUAqXSBNds+gwUHHBjEpcVCZ+Q8pIwDQYJKoZIhvcNAQEL
          BQAwbzELMAkGA1UEBhMCTloxEzARBgNVBAgMCkxvd2VyIEh1dHQxEzARBgNVBAcM
          CldlbGxpbmd0b24xITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDET
          MBEGA1UEAwwKYm9vbS5ib2F0czAeFw0yNTA5MTgwMTU2MTBaFw0zNTA5MTYwMTU2
          MTBaMG8xCzAJBgNVBAYTAk5aMRMwEQYDVQQIDApMb3dlciBIdXR0MRMwEQYDVQQH
          DApXZWxsaW5ndG9uMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQx
          EzARBgNVBAMMCmJvb20uYm9hdHMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
          AoIBAQCwli4U4bAmbi85HTyPXgiL6owGlotCo5osFIZ4dNgiylAcmc2P/WfLGA/e
          Qbfd9Zc2pZ1lHEcG0oN7YXOj0MQK7z0vvq23oNdVAQS3H/vW7+5T84SBSuMzCW1H
          O+Xwhv34lfYrOh1CTB3F2EqLoYeImlWCVn4tqMRP6UHQUvAv0AjWdobeqR/naq5s
          rjPoYSI6bv9PYjBXHFB3YOxlJ1Cn4yMWIqKVzqTFp9GYtw7RLV1YEbLDy6IQdvAZ
          25a69imLjO6TKJlqUIGzNOYlqUZfYrAR7RIJ3SIeFLgTiU4O0aLKIoK/kyEf/mMT
          /ENyf9TrlnBT8bNS+1Ct58IGm/QdAgMBAAGjUzBRMB0GA1UdDgQWBBRT3UeVA4tw
          Xb4SI++gUPoFAu1ygTAfBgNVHSMEGDAWgBRT3UeVA4twXb4SI++gUPoFAu1ygTAP
          BgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCWEDIKXeqp54wm97k+
          wvNTtK91LCZ/vvcgOKNoRE/t7+DkcG8zGFEg1Ls0KxvvD0/pU/7VndiIbkrubEg/
          o5CdZ/0Xao5+ct3x8+zWpMOQyGyCkWjzUAl80W42aUS2s61xAY7HIWqyLN26miF4
          gDXettOcDEQbey7aDTqmGW/0/6hP87ZISrzxS3+FauJMnAaF2Mi0Qr+1T4evqfUh
          njMQMVUbDwpReKDxkzyUvV+CO239WKqNF9zdhfe4cQMNvljqBCCUxJbIjna2t3Dv
          MP4ATkEJrD/7zgIl/Tw155HUfvki2OovNj04+7VwsyivNKU1l7XgGGLi6nPUzYBI
          hcyy
          -----END CERTIFICATE-----
        '');
        # verify = 2; # Verify server certificate
      };
    };
  };

  # enable auto-cpu freq, disable power profiles as it interferes
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  services.tlp.enable = true;

  services.netbird = {
    package = pkgs.netbird;
    enable = false;
  };

  services.undervolt = {
    enable = true;
    uncoreOffset = -130;
    coreOffset = -130;
  };

  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;

  system.stateVersion = "24.11";
}
