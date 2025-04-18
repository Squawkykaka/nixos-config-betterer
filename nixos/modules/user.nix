{ pkgs, user, ... }:
{
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
      isNormalUser = true;
      initialHashedPassword = "$6$ZOTGb9wnuJIyq5j1$UfS9gJ.hR3Fq9SQVUuoI/U51v2tUCAhGI25W1cI8M9jjxw/b0oha5dMrdEZGWj.yKjYo7I4R31Jb0oJr5UuYf0";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  # makes sudo not need a password
  security.sudo.extraRules = [
    {
      users = [ "${user}" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
