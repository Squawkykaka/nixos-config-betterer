{
  lib,
  pkgs,
  wrappers,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.self}/disks/btrfs-disk.nix"
    {
      _module.args = {
        disk = "/dev/sda1";
        withSwap = false;
      };
    }
  ];
  boot.loader.systemd-boot.enable = true;
  system.stateVersion = "25.11";
}
