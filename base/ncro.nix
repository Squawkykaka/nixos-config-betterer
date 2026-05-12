{
  self,
  pkgs,
  ...
}:
let
  ncro = pkgs.callPackage "${self.sources.ncro}/nix/package.nix";
  ncroModule = import "${self.sources.ncro}/nix/module.nix" false;
in
{
  imports = [
    ncroModule
  ];

  services.ncro = {
    package = ncro;
    settings = {
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
        }
        {
          url = "https://nix-community.cachix.org";
          priority = 20;
        }
      ];
    };
  };

  nix.settings.substituters = pkgs.lib.mkForce [ "http://localhost:8080" ];
}
