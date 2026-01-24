{ adios }:
{
  options = {
    policiesFiles.default = [
      ./policies/policies.json
      ./policies/preferences.json
    ];
    autoConfigFiles.default = [
      ./arkenfox.js
      ./override.js
    ];
  };
}
