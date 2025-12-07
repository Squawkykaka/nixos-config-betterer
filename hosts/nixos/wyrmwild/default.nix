{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = lib.flatten [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.disko
    (lib.custom.relativeToRoot "hosts/common/disks/btrfs-disk-impermanence.nix")
    {
      _module.args = {
        disk = "/dev/sda";
        withSwap = true;
        swapSize = "32";
      };
    }

    (map lib.custom.relativeToRoot [
      "hosts/common/core"
      "hosts/common/optional/impermanence.nix"
      "modules/common"
    ])
  ];

  hostSpec = {
    hostName = "wyrmwild";
    username = "gleask";
    persistFolder = "/persist";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  programs.ssh.startAgent = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";
}
