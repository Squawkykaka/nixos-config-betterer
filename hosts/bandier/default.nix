{
  pkgs,
  self,
  ...
}:
{
  imports = [
    "${self.sources.disko}/module.nix"
    ../../disks/btrfs-disk-luks.nix
    {
      _module.args = {
        disk = "/dev/sda";
        withSwap = true;
        swapSize = "8";
      };
    }
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
