{
  config,
  lib,
  pkgs,
  wrappers,
  ...
}:
{
  hm.home = {
    username = "gleask";
    homeDirectory = "/home/gleask";
    stateVersion = lib.mkDefault "24.11";
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

  environment.systemPackages = with pkgs; [
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
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
