{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.mango.nixosModules.mango];

  programs.mango.enable = true;

  environment.systemPackages = [
    pkgs.swww
    pkgs.grim
    pkgs.slurp
    pkgs.wmenu
  ];
}
