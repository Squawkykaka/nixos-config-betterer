{
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  fileSystems.${config.hostSpec.persistFolder}.neededForBoot = true;

  environment.persistence.${config.hostSpec.persistFolder} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.gleask = {
      directories = [
        "documents"
        "downloads"
        "media"
        "nixos"
        "Games"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
      ];
      files = [
        ".screenrc"
        ".config/sops/age/keys.txt"
      ];
    };
  };
}
