adios: {
  options = {
    package.defaultFunc = { inputs }: inputs.nixpkgs.pkgs.firefox-beta-unwrapped;
    policiesFiles.default = [
      ./policies/policies.json
      ./policies/preferences.json
      # ./policies/extensions.json
    ];

    autoConfigFiles.defaultFunc =
      { inputs }:
      let
        inherit (inputs.nixpkgs) pkgs;
        inherit (pkgs) replaceVars;
      in
      [
        (replaceVars ./autoConfig.js { userChromeFile = ./userChrome.css; })
      ];
  };
}
