{ promise, ... }: {
  inputs.dunst.from = { parent }: parent.dunst;
  options.configFiles.mutators = [ "/niri" ];
  mutations."/niri".configFiles = promise (
    { inputs }: [
      (toString ./config.kdl)
      (inputs.nixpkgs.pkgs.writeText "startup.kdl" /* kdl */ ''
        spawn-at-startup "${inputs.dunst { }}/bin/dunst"
        spawn-at-startup "${inputs.nixpkgs.pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
      '')
    ]
  );
}
