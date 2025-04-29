{ pkgs, ... }:
{
  #imports = [ ./foo.nix ];

  home.packages = builtins.attrValues {
    inherit (pkgs)
      #telegram-desktop
      vesktop
      slack
      whatsapp-for-linux
      ;
  };
}
