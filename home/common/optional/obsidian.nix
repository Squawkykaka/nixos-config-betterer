{ pkgs, ... }:
{
  home.packages = {
    inherit (pkgs)
      obsidian
      ;
  };
}
