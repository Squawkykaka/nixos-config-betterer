{ config, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases =
      let
        flakeDir = "~/nixos";
      in
      {
        sw = "nh os switch";
        upd = "nix flake update --flake ${flakeDir}";
        hms = "nh home switch";

        gs = "git status";
        ga = "git add";
        gc = "git commit";
        gp = "git push";

        ls = "eza";
        cat = "bat";

        ".." = "cd ..";
      };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    initExtra = ''
      eval "$(direnv hook zsh)"

      # Start UWSM
      if uwsm check may-start > /dev/null && uwsm select; then
        exec systemd-cat -t uwsm_start uwsm start default
      fi
    '';
  };
}
