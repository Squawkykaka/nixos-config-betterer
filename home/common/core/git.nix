{ pkgs, ... }:
{
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

    userName = "Squawkykaka";
    userEmail = "squawkykaka@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
