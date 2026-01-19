{
  description = "Squawkykaka's NixOS configuration";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;

      forAllSystems =
        apply:
        nixpkgs.lib.genAttrs [ "x86_64-linux" ] (
          system:
          apply (import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          }) system
        );

      recursivelyImport = import ./lib/default.nix { inherit (nixpkgs) lib; };

      specialArgs = {
        inherit inputs outputs;
        inherit (nixpkgs) lib;
        wrappers = inputs.self.wrappers."x86_64-linux";
      };
    in
    {
      #
      # ========= Overlays =========
      #
      # Custom modifications/overrides to upstream packages
      overlays = import ./overlays { inherit inputs; };

      #
      # ========= Host Configurations =========
      #
      # Building configurations is available through `just rebuild` or `nixos-rebuild --flake .#hostname`
      nixosConfigurations = {
        simba = nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs // {
            hostVars = {
              hostName = "simba";
              stateVersion = "24.11";
            };
          };
          modules = recursivelyImport [
            ./hosts/simba
            ./base
            ./desktop
          ];
        };
        sabaton = nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs // {
            hostVars = {
              hostName = "sabaton";
              stateVersion = "24.11";
            };
          };
          modules = recursivelyImport [
            ./hosts/sabaton
            ./base
            ./desktop
          ];
        };
        bingbong = nixpkgs.lib.nixosSystem {
          specialArgs = specialArgs // {
            hostVars = {
              hostName = "bingbong";
              stateVersion = "25.11";
            };
          };
          modules = recursivelyImport [
            ./hosts/bingbong
            ./base
          ];
        };
      };

      wrappers = forAllSystems (
        pkgs: system:
        import ./wrappers/default.nix {
          inherit pkgs;
          adios = inputs.adios.adios;
          adios-wrappers = inputs.adios-wrappers.wrapperModules;
        }
      );
      #
      # ========= Packages =========
      #
      # Expose custom packages
      packages = forAllSystems (
        pkgs: system:
        pkgs.lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.lib.callPackageWith pkgs;
          directory = ./packages;
        }
      );

      #
      # ========= Formatting =========
      #
      # Nix formatter available through 'nix fmt' https://github.com/NixOS/nixfmt
      formatter = forAllSystems (pkgs: _: pkgs.alejandra);
      # Pre-commit checks
      checks = forAllSystems (pkgs: system: import ./checks.nix { inherit inputs pkgs system; });

      #
      # ========= DevShell =========
      #
      devShells = forAllSystems (
        pkgs: system:
        import ./shell.nix {
          inherit pkgs;
          checks = self.checks.${system};
        }
      );
    };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://nixpkgs-unfree.cachix.org"
      "https://catppuccin.cachix.org"
      "https://cache.snix.dev"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      "cache.snix.dev-1:miTqzIzmCbX/DyK2tLNXDROk77CbbvcRdWA4y2F8pno="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.51.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    adios.url = "github:llakala/adios/providers-and-consumers";
    adios-wrappers = {
      url = "github:squawkykaka/adios-wrappers/add-helix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.adios.follows = "adios";
    };
  };
}
