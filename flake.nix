{
  description = "Squawkykaka's NixOS configuration";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # ========== Extend lib with lib.custom ==========
    lib = nixpkgs.lib.extend (_self: _super: {custom = import ./lib {inherit (nixpkgs) lib;};});

    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
  in {
    #
    # ========= Overlays =========
    #
    # Custom modifications/overrides to upstream packages
    overlays = import ./overlays {inherit inputs;};

    #
    # ========= Host Configurations =========
    #
    # Building configurations is available through `just rebuild` or `nixos-rebuild --flake .#hostname`
    nixosConfigurations =
      builtins.listToAttrs (
        map (host: {
          name = host;
          value = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs outputs lib;
            };
            modules = [./hosts/nixos/${host}];
          };
        }) (builtins.attrNames (builtins.readDir ./hosts/nixos))
      )
      // {
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {inherit inputs outputs;};
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
          ];
        };
      };

    #
    # ========= Packages =========
    #
    # Expose custom packages

    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };
      in
        nixpkgs.lib.packagesFromDirectoryRecursive {
          callPackage = nixpkgs.lib.callPackageWith pkgs;
          directory = ./packages;
        }
    );

    #
    # ========= Formatting =========
    #
    # Nix formatter available through 'nix fmt' https://github.com/NixOS/nixfmt
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    # Pre-commit checks
    checks = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./checks.nix {inherit inputs system pkgs;}
    );

    #
    # ========= DevShell =========
    #
    devShells = forAllSystems (
      system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          checks = self.checks.${system};
        }
    );
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
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
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
