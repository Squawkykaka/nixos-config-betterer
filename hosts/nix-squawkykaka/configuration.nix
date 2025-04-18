{ pkgs, stateVersion, hostname, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ./videodriver.nix
    ../../nixos/modules
  ];

  environment.systemPackages = [ pkgs.home-manager ];

  networking.hostName = hostname;

  system.stateVersion = stateVersion;

  # allow unfree for this machines
  nixpkgs.config.allowUnfree = true;

  # set up lanzaboote
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  boot.kernelModules = [ "kvm-intel" ];
}

