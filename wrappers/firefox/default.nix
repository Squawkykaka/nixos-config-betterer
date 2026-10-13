{ promise, ... }: {
  options = {
    policiesFiles.default = [
      ./policies/policies.json
      ./policies/preferences.json
      # ./policies/extensions.json
    ];
    autoConfigFiles.default = promise (
      { inputs }:
      let
        inherit (inputs.nixpkgs) pkgs;
        inherit (pkgs) replaceVars;
      in
      [
        (replaceVars ./autoConfig.js { userChromeFile = ./userChrome.css; })
      ]
    );
  };
}
