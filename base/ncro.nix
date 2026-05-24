{
  pkgs,
  ...
}:
let
  ncroModule = import /home/gleask/documents/projects/public/ncro/nix/module.nix;
in
{
  imports = [
    ncroModule
  ];

  services.ncro = {
    enable = true;
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
