# Shell for bootstrapping flake-enabled nix and other tooling
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  nativeBuildInputs = builtins.attrValues {
    inherit (pkgs)
      pre-commit
      npins
      nix-output-monitor
      sops
      ;
  };
}
