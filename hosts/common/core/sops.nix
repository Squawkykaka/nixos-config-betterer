{
  inputs,
  config,
  pkgs,
  ...
}: {
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
    age.keyFile = "/home/${config.hostSpec.username}/.config/sops/age/keys.txt";

    secrets = {
      "users/${config.hostSpec.username}/password" = {
        neededForUsers = true;
      };
      "email" = {};

      "sabaton/wireguard/privkey" = {
        mode = "0600";
      };

      "simba/wireguard/privkey" = {
        mode = "0600";
      };
    };
  };
}
