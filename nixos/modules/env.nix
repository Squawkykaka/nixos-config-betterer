{
  environment.sessionVariables = rec {
    TERMINAL = "ghostty";
    EDITOR = "nvim";
    XDG_BIN_HOME = "$HOME/.local/bin";
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/gleask/.steam/root/compatibilitytools.d";
    PATH = [
      "${XDG_BIN_HOME}"
    ];
  };
}
