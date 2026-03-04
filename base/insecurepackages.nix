{
  # i wanna eval on all systems
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
}
