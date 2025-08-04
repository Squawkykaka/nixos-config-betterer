{pkgs, ...}: {
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
}
