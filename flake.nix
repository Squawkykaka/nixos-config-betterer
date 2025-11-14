{
  description = "Squawkykaka's NixOS configuration";

  outputs = {
    self,
    nixpkgs,
    snix,
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

    lib.hostsBySystem = system: let
      self = inputs.self;
      where =
        if lib.hasSuffix "darwin" system
        then self.darwinConfigurations
        else self.nixosConfigurations;
      sameSystem = lib.filterAttrs (_: v: v.config.nixpkgs.hostPlatform.system == system) where;
    in
      lib.attrNames sameSystem;

    #
    # ========= Host Configurations =========
    #
    # Building configurations is available through `just rebuild` or `nixos-rebuild --flake .#hostname`
    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              outputs
              lib
              snix
              ;
          };
          modules = [./hosts/nixos/${host}];
        };
      }) (builtins.attrNames (builtins.readDir ./hosts/nixos))
    );

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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snix = {
      url = "git+https://git.snix.dev/snix/snix";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
