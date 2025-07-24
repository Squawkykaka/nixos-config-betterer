{pkgs, ...}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      bitwarden-desktop
      ;
  };
}
