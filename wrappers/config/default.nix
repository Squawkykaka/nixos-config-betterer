{ wrappers, ... }:
{
  git = wrappers.git {
    ignores = [
      ".csvignore"
      # nix
      "*.drv"
      "result"
      # python
      "*.py?"
      "__pycache__/"
      ".venv/"
      # direnv
      ".direnv"
    ];
    settings = {
      user.name = "Squawkykaka";
      user.email = "squawkykaka@gmail.com";

      # gpg.format = "ssh";
      init.defaultBranch = "main";
    };
    signing = {
      format = "ssh";
      key = "/home/gleask/.ssh/id_ed25519";
      signByDefault = true;
    };
  };
  fish = wrappers.fish { };
  ssserver = wrappers.ssserver { };
  helix = wrappers.helix {
    settings = {
      theme = "gruvbox";

      editor = {
        line-number = "relative";
        mouse = false;
      };
    };
  };
  nushell = wrappers.nushell { };
}
