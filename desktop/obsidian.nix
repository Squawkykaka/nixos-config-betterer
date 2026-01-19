{ pkgs, ... }:
{
  hm.home.packages = builtins.attrValues {
    inherit (pkgs)
      obsidian
      ;
  };
}
