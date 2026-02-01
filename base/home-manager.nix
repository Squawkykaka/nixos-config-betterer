{
  pkgs,
  self,
  lib,
  ...
}:

{
  imports = [
    (import "${self.sources.home-manager}/nixos")

    # Let us use hm as shorthand for home-manager config
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" "gleask" ])
  ];

  # make home-manager backup files.
  home-manager.backupFileExtension = "bk";

  home-manager = {
    extraSpecialArgs = {
      inherit
        pkgs
        self
        ;
    };
  };
  hm.home.stateVersion = self.hostVars.stateVersion;
}
