{
  config,
  lib,
  pkgs,
  wrappers,
  hostSpec,
  ...
}:
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/common/host-spec.nix"
      # "modules/home"
    ])

    ./zsh.nix
    ./zoxide.nix
    ./xdg.nix
    ./neovim.nix
    ./stylix.nix
    ./direnv.nix
  ];

  inherit hostSpec;

  programs.git.enable = false;

  programs.nh = {
    enable = true;
    # clean.enable = true;
    # clean.extraArgs = "--keep-since 4d --keep 3";
  };

  home = {
    username = lib.mkDefault config.hostSpec.username;
    homeDirectory = lib.mkDefault config.hostSpec.home;
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

  home.packages =
    builtins.attrValues {
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
        nixd # nix language server
        nixfmt-rfc-style # nix formatter
        tldr # very nice short descriptions
        zip
        wget
        killall
        lm_sensors
        cava
        ;
    }
    ++ [
      wrappers.git
      wrappers.helix
    ];

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
