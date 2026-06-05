{ self, ... }:
{
  image.modules = {
    minimal = (self.sources.nixpkgs + /nixos/modules/installer/cd-dvd/installation-cd-minimal.nix);
  };

}
