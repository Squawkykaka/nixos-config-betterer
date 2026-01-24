{ adios }:
{
  options = {
    policiesFiles.default = [
      ./policies/policies.json
      ./policies/preferences.json
      ./policies/preferences.json
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
