{
  pkgs,
  inputs,
  ...
}:
{
  hm.home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
