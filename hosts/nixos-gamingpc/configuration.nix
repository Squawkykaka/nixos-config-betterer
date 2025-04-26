{ pkgs, stateVersion, hostname, ... }:

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

  time.hardwareClockInLocalTime = true;
  
# allow unfree for this machines
  nixpkgs.config.allowUnfree = true;

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
}

