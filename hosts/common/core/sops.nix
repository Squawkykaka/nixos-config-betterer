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

  environment.systemPackages = [ pkgs.sops ];

  sops = {
    defaultSopsFile = ../../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${config.hostSpec.username}/.config/sops/age/keys.txt";

    secrets = {
      "users/${config.hostSpec.username}/password" = {
        neededForUsers = true;
      };

      "borg_pass" = {
        owner = "root";
        group = "wheel";
        mode = "0600";
        path = "/etc/borg/passphrase";
      };
    };
  };
}
