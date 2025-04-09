{ inputs, ...}: {
  # import lix
  imports = [ inputs.lix-module.nixosModules.default ]
}