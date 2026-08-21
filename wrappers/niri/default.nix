_: {
  options.configFiles.mutators = [ "/niri" ];
  mutations."/niri".configFiles = { inputs }: [
    (toString ./config.kdl)
    (inputs.nixpkgs.pkgs.writeText "startup.kdl" /* kdl */ ''
      spawn-at-startup "${inputs.nixpkgs.pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
    '')
  ];
}
