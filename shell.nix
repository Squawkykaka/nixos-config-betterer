# Shell for bootstrapping flake-enabled nix and other tooling
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
  # pre-commit = sources."git-hooks.nix" {};

  pre-commit-check = import ./checks.nix { inherit sources; };
in
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";

  inherit (pre-commit-check) shellHook;
  buildInputs = pre-commit-check.enabledPackages;

  nativeBuildInputs = builtins.attrValues {
    inherit (pkgs)
      git
      pre-commit
      npins
      nix-output-monitor
      sops
      ;
  };
}
