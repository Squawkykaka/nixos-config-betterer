{
  config,
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
    noto-fonts-emoji
    font-awesome
    powerline-fonts
    powerline-symbols
    nerd-fonts.jetbrains-mono
  ];

  stylix = {
    enable = true;
    base16Scheme = config.home-manager.users.gleask.stylix.base16Scheme;

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

  hm = {
    stylix = {
      enable = true;
      targets = {
        neovim.enable = false;
        waybar.enable = false;
        wofi.enable = false;
        hyprland.enable = false;
        hyprlock.enable = false;
        firefox.enable = false;
        bat.enable = false;
        vscode.enable = false;
      };

      # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

      # image = pkgs.fetchurl {
      #   url = "https://codeberg.org/lunik1/nixos-logo-gruvbox-wallpaper/raw/branch/master/png/gruvbox-dark-rainbow.png";
      #   sha256 = "036gqhbf6s5ddgvfbgn6iqbzgizssyf7820m5815b2gd748jw8zc";
      # };

      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/dracula/wallpaper/refs/heads/master/first-collection/nixos.png";
        sha256 = "sha256-hJBs+1MYSAqxb9+ENP0AsHdUrvjTzjobGv57dx5pPGE=";
      };
    };
  };
}
