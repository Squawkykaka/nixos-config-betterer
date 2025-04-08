{ inputs, ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2 ];
}