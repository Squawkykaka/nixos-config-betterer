{
  pkgs,
  wrappers,
  self,
  lib,
  inputs,
  hostVars,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager

    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "gleask" ])
  ];

  # make home-manager backup files.
  home-manager.backupFileExtension = "bk";

  home-manager = {
    extraSpecialArgs = {
      inherit
        pkgs
        inputs
        self
        wrappers
        hostVars
        ;
    };
  };
  hm.home.stateVersion = hostVars.stateVersion;
}
