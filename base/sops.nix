{
  self,
  pkgs,
  ...
}:
{
  imports = [
    "${self.sources.sops-nix}/modules/sops"
  ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/keys.txt";

    secrets = {
      "users/gleask/password" = {
        neededForUsers = true;
      };
      "email" = { };
    };
  };
}
