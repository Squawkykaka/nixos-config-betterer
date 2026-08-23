_: {
  inputs.git.from = { parent }: parent.git;
  options.ignoredPaths.defaultFunc = { inputs }: inputs.git.ignoredPaths;
  options.settings.default = {
    user = {
      name = "Squawkykaka";
      email = "contact@squawkykaka.com";
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
