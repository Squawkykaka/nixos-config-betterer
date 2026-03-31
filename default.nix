let
  sources = import ./npins { };
  overlay = (import ./overlays { }).default;

  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
    overlays = [ overlay ];
  };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./lib { inherit (pkgs) lib; };

  wrappers = import ./wrappers { inherit pkgs sources; };

  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  forAllSystems =
    set:
    let
      lib = import "${sources.nixpkgs}/lib";
    in
    lib.genAttrs systems (
      system:
      set (import sources.nixpkgs {
        system = system;
        overlays = [ overlay ];
      }) system
    );

  mkHost =
    hostVars:
    nixosSystem {
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

  packages = forAllSystems (
    pkgs: _:
    pkgs.lib.packagesFromDirectoryRecursive {
      callPackage = pkgs.lib.callPackageWith pkgs;
      directory = ./packages;
    }
  );

  inherit wrappers;
}
