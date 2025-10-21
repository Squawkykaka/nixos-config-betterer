{pkgs, ...}: {
  programs.lazygit.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

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

      init.defaultBranch = "main";
    };

    signing = {
      format = "openpgp";
      key = "EEE6D399CBF032538BB85DE421DE591A2CFFC23D";
      signByDefault = true;
    };
  };
}
