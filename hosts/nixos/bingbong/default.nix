{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports =
    [
      ./hardware-configuration.nix
      (modulesPath + "/profiles/qemu-guest.nix")
    ]
    ++ (map lib.custom.relativeToRoot [
      "hosts/common/core"
    ]);

  hostSpec = {
    hostName = "bingbong";
    username = "gleask";
    persistFolder = "/persist";
  };

  services.cloud-init.network.enable = true;

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.grub.devices = ["nodev"];
  boot.growPartition = true;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
  programs.ssh.startAgent = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "25.11";
}
