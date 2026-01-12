{ adios }:
{
  options.settings.mutators = [ "/git" ];
  mutations."/git".settings =
    { }:
    {
      user = {
        name = "Squawkykaka";
        email = "squawkykaka@gmail.com";

        init.defaultBranch = "main";
        signingKey = "/home/gleask/.ssh/id_ed25519";
      };
      commit.gpgSign = true;
      tag.gpgSign = true;
      gpg.format = "ssh";
    };
  options.ignoredPaths.default = [
    ".csvignore"
    # nix
    "*.drv"
    "result"
    # python
    "*.py?"
    "__pycache__/"
    ".venv/"
    # direnv
    ".direnv"
  ];
}
