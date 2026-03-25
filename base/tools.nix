{
  pkgs,
  ...
}:
{
  hm.home = {
    username = "gleask";
    homeDirectory = "/home/gleask";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      FLAKE = "$HOME/nixos";
      TERM = "ghostty";
      TERMINAL = "ghostty";
      VISUAL = "hx";
      EDITOR = "hx";
    };
    preferXdgDirectories = true; # whether to make programs use XDG directories whenever supported
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    jujutsu
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
    jujutsu
    krita
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
