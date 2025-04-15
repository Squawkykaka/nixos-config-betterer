{ system, ... }:
{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      inherit system;
      hostName = "100.64.0.6";
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
      supportedFeatures = [
        "nixos-test"
        "big-parallel"
        "kvm"
      ];
    }
  ];
}
