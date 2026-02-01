let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {
    config.allowUnfree = true;
  };
  nixosSystem = import "${sources.nixpkgs}/nixos/lib/eval-config.nix";
  recursivelyImport = import ./lib { inherit (pkgs) lib; };

  wrappers = import ./wrappers { inherit pkgs sources; };

  mkHost =
    hostVars:
    nixosSystem {
      specialArgs.self = {
        inherit hostVars sources wrappers;
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
  };

  packages = pkgs.lib.packagesFromDirectoryRecursive {
    callPackage = pkgs.lib.callPackageWith pkgs;
    directory = ./packages;
  };

  inherit wrappers;
}
