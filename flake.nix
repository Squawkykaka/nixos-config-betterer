{
  description = "My new nixos configuration";

  outputs = { self, nixpkgs, home-manager, stylix, nixos-hardware, lanzaboote, blocklist-hosts, lix-module, ... } @ inputs: let 
    system = "x86_64-linux";
    homeStateVersion = "24.11";
    user = "gleask";
    locale = "en_NZ.UTF-8";

    pkgs = nixpkgs.legacyPackages.${system};

    hosts = [
      { hostname = "nix-squawkykaka"; stateVersion = "24.11"; }
    ];

    makeSystem = { hostname, stateVersion }: nixpkgs.lib.nixosSystem {
      system = system;
      specialArgs = {
        inherit inputs stateVersion hostname user locale;
      };

      modules = [
        ./hosts/${hostname}/configuration.nix
      ];
    };
  in {
    # making the nixos system by passing in the list of hosts as host and a blank config then concatenating a new config for that host.
    nixosConfigurations = nixpkgs.lib.foldl' (configs: host:
      configs // {
        "${host.hostname}" = makeSystem {
          inherit (host) hostname stateVersion;
        };
      }) {} hosts;

    homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      extraSpecialArgs = {
        inherit inputs homeStateVersion user;
      };

      modules = [
        ./home-manager/home.nix
      ];
    };
  };


  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
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
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

}