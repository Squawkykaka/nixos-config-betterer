{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gcc
    jetbrains.idea-ultimate
    jdk17
    sbctl

    (lutris.override {
      extraPkgs = pkgs: [
        wineWowPackages.stable
        gamescope
      ];
    })
  ];
}
