{
  self,
  ...
}:
{
  hm.home.packages = [
    self.wrappers.firefox.drv
  ];
}
