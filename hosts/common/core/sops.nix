{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment.systemPackages = [
    pkgs.sops
    pkgs.age
  ];

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/root/keys.txt";

    secrets = {
      "users/${config.hostSpec.username}/password" = {
        neededForUsers = true;
      };
      "email" = { };
    };
  };
}
