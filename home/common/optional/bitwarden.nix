{ pkgs, ... }:
{
  home.packages = {
    inherit (pkgs)
      bitwarden-desktop
      ;
  };
}
