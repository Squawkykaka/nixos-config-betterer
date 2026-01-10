{ adios }:
let
  inherit (adios) types;
in
{
  name = "zoxide";

  mutations."/nushell".settings = { inputs, options }: builtins.readFile ./config.nu;
}
