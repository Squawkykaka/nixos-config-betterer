{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.stylix.nixosModules.stylix];

  environment.systemPackages = with pkgs; [
    dejavu_fonts
    noto-fonts
    noto-fonts-lgc-plus
    texlivePackages.hebrew-fonts
    noto-fonts-color-emoji
    font-awesome
    powerline-fonts
    powerline-symbols
    nerd-fonts.jetbrains-mono
  ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    cursor = {
      name = "Bibata-Modern-Ice";
      size = 28;
      package = pkgs.bibata-cursors;
    };

    fonts = {
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };

      monospace = {
        name = "JetBrainsMono Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };

      sizes = {
        terminal = 13;
        applications = 12;
      };
    };
  };
}
