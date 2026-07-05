_: {
  options = {
    package.defaultFunc = { inputs }: inputs.nixpkgs.pkgs.mango;
    configFile.default = toString ./config.conf;
    autostartFile.default = toString ./autostart.sh;
  };
}
