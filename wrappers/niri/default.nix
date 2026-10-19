{ promise, types, ... }: {
  inputs.dunst.from = { parent }: parent.dunst;
  options.configFiles.mutators = [ "/niri" ];
  options.wallpaper = {
    type = types.path;
    # from dharmx/walls
    default = ./wallpaper.png;
  };
  mutations."/niri".configFiles = promise (
    {
      inputs,
      options,
      results,
    }:
    let
      inherit (inputs.nixpkgs.pkgs.lib) getExe;
      inherit (inputs.nixpkgs.pkgs) wbg playerctl swaylock-effects;
      inherit (builtins) genList;
      concat = builtins.concatStringsSep "\n";

      playerctl' = getExe playerctl;
      kb = {
        playerPlay = "${playerctl'} play-pause";
        playerStop = "${playerctl'} stop";
        playerPrev = "${playerctl'} previous";
        playerNext = "${playerctl'} next";
        lock = "${getExe swaylock-effects} --screenshots --clock --timestr %H:%M --effect-blur 16x8 --fade-in 0";
      };

      workspaceBinds = map (n: ''
        Mod+${n} { focus-workspace ${n}; }
        Mod+Shift+${n} { move-column-to-workspace ${n}; }
      '') (genList (x: toString (x + 1)) 9);

      apps = [
        "^com.mitchellh.ghostty$"
        "^org.prismlauncher.PrismLauncher$"
      ];
      opacityRule = focused: opacity: ''
        window-rule {
          ${concat (map (app: "match app-id=r#\"${app}\"# is-focused=${focused}") apps)}
          opacity ${opacity}
        }
      '';
    in
    [
      (toString ./config.kdl)
      (inputs.nixpkgs.pkgs.writeText "startup.kdl" /* kdl */ ''
        spawn-at-startup "${results.dunst}/bin/dunst"
        spawn-at-startup "${inputs.nixpkgs.pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
        spawn-at-startup "${getExe wbg} ${options.wallpaper}"

        ${opacityRule "true" "0.92"}
        ${opacityRule "false" "0.90"}

        binds {
          ${concat workspaceBinds}

          Mod+Shift+Equal { spawn-sh "${kb.lock}"; }

          XF86AudioPlay allow-when-locked=true { spawn-sh "${kb.playerPlay}"; }
          XF86AudioStop allow-when-locked=true { spawn-sh "${kb.playerStop}"; }
          XF86AudioPrev allow-when-locked=true { spawn-sh "${kb.playerPrev}"; }
          XF86AudioNext allow-when-locked=true { spawn-sh "${kb.playerNext}"; }
        }
      '')
    ]
  );
}
