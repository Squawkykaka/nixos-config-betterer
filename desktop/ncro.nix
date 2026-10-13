{
  self,
  pkgs,
  lib,
  ...
}:
{
  imports = [ (self.sources.ncro + /nix/module.nix) ];
  services.ncro = {
    enable = true;
    package = pkgs.callPackage (self.sources.ncro + /nix/package.nix) { };
    settings.upstreams = [
      {
        url = "https://cache.nixos.org";
        priority = 20;
        public_key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
      }
      {
        url = "https://nix-gaming.cachix.org";
        priority = 5;
        public_key = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
      }
      {
        url = "https://nix-community.cachix.org";
        priority = 10;
        public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      }
    ];
    settings.discovery = {
      enabled = true;
      address_family = "ipv6";
    };
  };
  nix.settings.substituters = lib.mkForce [ "http://localhost:8080" ];
}
