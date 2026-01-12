{ adios }:
let
  inherit (adios) types;
in
{
  name = "git";

  inputs = {
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    package = {
      type = types.derivation;
      defaultFunc = { inputs }: inputs.nixpkgs.pkgs.gitFull;
    };
    ignores = {
      type = types.listOf types.str;
      default = [ ];
    };
    settings = {
      type = types.attrs;
      default = { };
    };
    signing = {
      type =
        (types.struct "signing" {
          format = types.option (
            types.enum "signingFormat" [
              "openpgp"
              "ssh"
              "x509"
            ]
          );
          key = types.str;
          signByDefault = types.bool;
        }).override
          { total = false; unknown = false; };
      default = { };
    };
  };

  impl =
    {
      options,
      inputs,
    }:
    let
      inherit (inputs.nixpkgs) pkgs lib;
      inherit (pkgs)
        symlinkJoin
        makeWrapper
        linkFarm
        writeText
        ;
      inherit (lib.generators) toGitINI;
      inherit (lib) concatStringsSep;

      iniConfig = lib.foldl' lib.recursiveUpdate { } [
        options.settings
        (lib.optionalAttrs (options.signing ? key) {
          user.signingKey = options.signing.key;
        })
        (lib.optionalAttrs (options.signing ? signByDefault && options.signing.signByDefault == true) {
          commit.gpgSign = true;
          tag.gpgSign = true;
        })
        (lib.optionalAttrs (options.signing ? format) {
          gpg = {
            format = options.signing.format;
          };
        })
      ];
    in
    symlinkJoin {
      name = "git-wrapped";
      paths = [
        options.package
        (linkFarm "gitconfig" [
          {
            name = "git/config";
            path = writeText "config" (toGitINI iniConfig);
          }
          {
            name = "git/ignore";
            path = writeText "ignore" (concatStringsSep "\n" options.ignores + "\n");
          }
        ])
      ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = /* bash */ ''
        wrapProgram $out/bin/git \
        	--set XDG_CONFIG_HOME $out
      '';
      meta.mainProgram = "git";
    };
}
