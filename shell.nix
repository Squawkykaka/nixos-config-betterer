# Shell for bootstrapping flake-enabled nix and other tooling
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    npins
    sops
  ];
  buildInputs = with pkgs; [
    kdePackages.qtdeclarative
    kdePackages.qt5compat
  ];
  shellHook = ''
    export QML_IMPORT_PATH=$PWD/src
  '';
}
