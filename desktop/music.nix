{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [ ytmdesktop ];
}
