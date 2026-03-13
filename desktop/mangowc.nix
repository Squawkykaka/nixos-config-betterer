{ pkgs, self, ... }:
{
  programs.mangowc.enable = true;
  programs.mangowc.package = self.wrappers.mangowc.drv;

  environment.systemPackages = [ pkgs.eww ];
}
