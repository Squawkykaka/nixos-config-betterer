{ inputs, pkgs, ... }:
{
  hm.imports = [ inputs.stylix.homeModules.stylix ];

  hm.stylix = {
    enable = true;
    targets = {
      neovim.enable = false;
      kde.enable = false;
      qt.enable = false;
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
  };
}
