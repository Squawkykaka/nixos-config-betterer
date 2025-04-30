{
  config,
  lib,
  pkgs,
  hostSpec,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/common/host-spec.nix"
      # "modules/home"
    ])

    ./zsh
    ./git.nix
    ./xdg.nix
    ./eza.nix
    ./ghostty.nix
    ./neovim.nix
    ./stylix.nix
    ./direnv.nix
    ./bat.nix
    ./zoxide.nix
  ];

  inherit hostSpec;

  programs.nh = {
    enable = true;
    # clean.enable = true;
    # clean.extraArgs = "--keep-since 4d --keep 3";
  };

  services.ssh-agent.enable = true;

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
    stateVersion = lib.mkDefault "24.11";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      FLAKE = "$HOME/nixos";
      SHELL = "zsh";
      TERM = "ghostty";
      TERMINAL = "ghostty";
      VISUAL = "nvim";
      EDITOR = "nvim";
      MANPAGER = "batman"; # see ./cli/bat.nix
    };
    preferXdgDirectories = true; # whether to make programs use XDG directories whenever supported
  };

  home.packages = builtins.attrValues {
    inherit (pkgs)
      btop # resource monitor
      coreutils # basic gnu utils
      curl
      fzf # nice fuzzyfind
      fastfetch # come on, we need it
      pciutils
      pfetch # system info
      pre-commit # git hooks
      ripgrep # better grep
      tree # cli dir tree viewer
      unzip
      nil # nix language server
      nixfmt-rfc-style # nix formatter
      zip
      wget
      killall
      ;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
