{ self, ... }:
{
  environment.systemPackages = [ self.wrappers.direnv.drv ];
}
