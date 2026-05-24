{
  pkgs,
  self,
  ...
}:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    ncdu
    (self.wrappers.jujutsu.drv)
    libqalculate
    neovim
    btop # resource monitor
    coreutils # basic gnu utils
    curl
    fzf # nice fuzzyfind
    fastfetch # come on, we need it
    pre-commit # git hooks
    ripgrep # better grep
    tree # cli dir tree viewer
    unzip
    nixd # nix language server
    nixfmt
    tldr # very nice short descriptions
    zip
    magic-wormhole
    wireshark
    inetutils
    net-tools
    unixtools.arp
    dig
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
