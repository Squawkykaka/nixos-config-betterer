{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
  ];

  environment.systemPackages = [ pkgs.zfs ];

  boot.kernelPackages = latestKernelPackage;

  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "xfs"
    "ntfs"
    "cifs"
  ];

  # rootboy
  users.users.root.hashedPassword = "$y$j9T$7hAny2okGFL7iKp.2hX4M0$MlaJ7DJ1ctTDCi7Y/uOCzZOetDANXH1QV3nERBpc8Y2";
  users.mutableUsers = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC58/7rbrdDn7XCpyRE73bEYysoGiMVWnhk8qxLHcnRbCJyZyeUI5JFrKbgEQHVNYqL1qntCGMwu7N4TLV8Olt74TtoBAWVXdGUb9TUT8CPd9u0t5KAae5slrORfzi7RaRU+Tcok/kYcy8CrzYrM6vRVPSnN8ajtgb28l2+eKSNNjrhnHvJc+PmcYCJUWytwjvYyesgvzuH/oAnRs3gIWIa+BZGIWc6Kiw9ih9HV88weeyu2oa94i2053LPmEhn4dviziKeln0i2aHSBsx+bJYdjjUnlPu6+tJa/w67/DOBtHJtafGfXocEwI7LNS50DdS+hjZpTqNNjhkQoVxxS3SuJbHsBPq5f+hJuATiky2uLeB8DCQwhZrI9Lr5YxafjrcszfbfgyyBf7BTxbRdTgF5ncV68adqnbMkniNwSo/2N5frFBCOCMCyk3qK64Xf3En58u+58RR3FzZqcVb5HU/yo148Dw546rKcJ8JhcfoLBg8ptTTfSCJFS0GhN5jozuF/udB7TVoVEVfbb3fWnpAb4+eaZUk8r+qSup49eFzbLeJnWCG1rY6Yl8zg3TTjq97d6bsjdKHY0wcgCMjIIBx2Eo6zVtdvj5APc1WnRru+Dx3URaRfU8JqRSnD0xJenBWrEyNBAbwcG7iKw+uZBfT7vqvcLh3EaT7u+KU9AyS4UQ== openpgp:0x17A0BD11"
  ];
}
