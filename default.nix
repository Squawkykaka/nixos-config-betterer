let
  sources = import ./npins { };

  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
    overlays = [
      (
        final: prev:
        prev.lib.packagesFromDirectoryRecursive {
          callPackage = prev.lib.callPackageWith final;
          directory = ./packages;
        }
      )
    ];
    config.permittedInsecurePackages = [
      "olm-3.2.16"
    ];
  };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  wrappers = import ./wrappers { inherit pkgs sources; };
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

    iso = mkHost {
      hostname = "iso";
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
