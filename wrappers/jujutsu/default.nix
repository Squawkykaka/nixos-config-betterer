_: {
  options.settings.default = {
    user = {
      name = "Squawkykaka";
      email = "me@squawkykaka.com";
    };
    signing = {
      backend = "ssh";
      behavior = "own";
      key = "~/.ssh/id_ed25519.pub";
    };
    aliases = {
      st = [ "status" ];
    };
  };
}
