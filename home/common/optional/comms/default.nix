{pkgs, ...}: {
  imports = [./mpv.nix];

  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      #telegram-desktop
      vesktop
      # FIXME has wierd graphical issues on hyprland
      # slack
      ;
  };
}
