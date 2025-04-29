{ lib, pkgs, ... }:
{
  imports = lib.custom.scanPaths ./.;

  home.packages = lib.flatten [
    (builtins.attrValues {
      inherit (pkgs)
        # Development
        direnv
        delta # diffing
        vscodium
        act # github workflow runner
        gh # github cli
        glab # gitlab cli
        yq-go # Parser for Yaml and Toml Files, that mirrors jq

        # nix
        nixpkgs-review

        # networking
        nmap

        # Diffing
        difftastic

        # devops
        ansible

        # serial debugging
        screen

        # Standard man pages for linux API
        man-pages
        man-pages-posix
        ;
    })
  ];
}
