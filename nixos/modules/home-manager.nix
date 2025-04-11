{ inputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  home-manager.backupFileExtension = "rebuild";

  # delete the homemanager backup files
  system.userActivationScripts = {
    removeConflictingFiles = {
      text = ''
        find ~ -type f -name "*.rebuild" -delete
      '';
    };
  };
}
