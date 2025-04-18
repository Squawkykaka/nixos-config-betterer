{ inputs, ... }:
{
  imports = [
    inputs.blocklist-hosts.nixosModule
  ];

  networking.stevenBlackHosts = {
    enableIPv6 = false;
    blockFakenews = true;
    blockGambling = true;
    blockPorn = true;
    blockSocial = false;
  };
}
