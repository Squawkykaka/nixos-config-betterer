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

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
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
      nixfmt-rfc-style # nix formatter
      tldr # very nice short descriptions
      zip
      ;
  };
}
