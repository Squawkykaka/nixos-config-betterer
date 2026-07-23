# User config applicable to both nixos and darwin
{
  config,
  self,
  ...
}:
{
  users.mutableUsers = false;
  users.users.gleask = {
    name = "gleask";
    isNormalUser = true;
    shell = self.wrappers.nushell.drv; # default shell
    hashedPasswordFile = config.sops.secrets."users/gleask/password".path;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos
    openssh.authorizedKeys.keys = map (file: builtins.readFile ./keys/${file}) (
      builtins.attrNames (builtins.readDir ./keys)
    );
  };
}
