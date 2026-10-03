{ promise, ... }: {
  options = {
    package.default = promise (
      { inputs }:
      inputs.nixpkgs.pkgs.firefox-beta-unwrapped
    );
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
