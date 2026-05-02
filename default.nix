let
  sources = import ./npins { };
  overlay = (import ./overlays { }).default;

  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
    overlays = [ overlay ];
  };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  wrappers = {
    x86_64-linux = import ./wrappers { inherit pkgs sources; };
    aarch64-linux = import ./wrappers {
      inherit sources;
      pkgs = pkgs.pkgsCross.aarch64-multiplatform;
    };
  };
  mkHost =
    hostVars:
    let
      recursivelyImport = import ./lib { inherit (pkgs) lib; };
    in
    nixosSystem {
      inherit pkgs;
      specialArgs.self = {
        inherit
          hostVars
          sources
          wrappers
          ;
      };
      modules = recursivelyImport (
        [
          ./hosts/${hostVars.hostname}
          ./base
        ]
        ++ (if hostVars ? desktop then [ ./desktop ] else [ ])
      );
    };
in
{
  nixosConfigurations = {
    simba = mkHost {
      hostname = "simba";
      stateVersion = "24.11";
      desktop = true;
    };

    sabaton = mkHost {
      hostname = "sabaton";
      stateVersion = "24.11";
      desktop = true;
    };

    bingbong = mkHost {
      hostname = "bingbong";
      stateVersion = "25.11";
    };

    kiri = mkHost {
      hostname = "kiri";
      stateVersion = "26.05";
    };

    zhara = mkHost {
      hostname = "zhara";
      stateVersion = "26.05";
    };

    # vps
    bandier = mkHost {
      hostname = "bandier";
      stateVersion = "26.05";
    };
  };

  packages = {
    x86_64-linux = pkgs.lib.packagesFromDirectoryRecursive {
      callPackage = pkgs.lib.callPackageWith pkgs;
      directory = ./packages;
    };
    aarch64-linux = pkgs.lib.packagesFromDirectoryRecursive {
      callPackage = pkgs.lib.callPackageWith pkgs.pkgsCross.aarch64-multiplatform;
      directory = ./packages;
    };
  };
  inherit wrappers;
}
