{
  description = "My new nixos configuration";

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      nixos-hardware,
      lanzaboote,
      blocklist-hosts,
      lix-module,
      solaar,
      ...
    }@inputs:
    let
      # these are editable attributes for all systems, TODO: move this into the per-system config
      system = "x86_64-linux";
      homeStateVersion = "24.11";
      user = "gleask";
      locale = "en_NZ.UTF-8";

      pkgs = nixpkgs.legacyPackages.${system};

      # define each host
      hosts = [
        {
          hostname = "nix-squawkykaka";
          stateVersion = "24.11";
        }
        {
          hostname = "nixos-gamingpc";
          stateVersion = "24.11";
        }
      ];

      # define the makeSystem function, this takes in the
      # stateversion and hostname and spits out a config pointing to the right directory
      makeSystem =
        { hostname, stateVersion }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              stateVersion
              hostname
              user
              locale
              ;
          };

          modules = [
            ./hosts/${hostname}/configuration.nix
          ];
        };
    in
    {
      # this function iterates over every host by creating a blank attributes set and passing in the hosts list
      # it then appends the config of the hosts to the set for each host.
      # // merges
      # an example output is:
      # nixosConfigurations = {
      # "host1" = makeSystem { hostname = "host1"; stateVersion = "23.05"; };
      # "host2" = makeSystem { hostname = "host2"; stateVersion = "23.05"; };
      # };
      nixosConfigurations = nixpkgs.lib.foldl' (
        # take the previous config and append the new one
        configs: host:
        configs
        // {
          "${host.hostname}" = makeSystem {
            inherit (host) hostname stateVersion;
          };
        }
      ) { } hosts;

      # make the home-mananger configs TODO: seperate so that different parts can be disabled individually
      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit
            inputs
            homeStateVersion
            user
            system
            ;
        };

        modules = [
          ./home-manager/home.nix
        ];
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blocklist-hosts = {
      url = "github:StevenBlack/hosts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    solaar = {
      url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz"; # For latest stable version
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
