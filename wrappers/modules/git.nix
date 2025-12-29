{adios}: let
  inherit (adios) types;
in {
  name = "git";

  inputs = {
    nixpkgs.path = "/nixpkgs";
  };

  options = {
    package = {
      type = types.derivation;
      defaultFunc = {inputs}: let
        inherit (inputs.nixpkgs) pkgs;
      in
        pkgs.gitFull;
    };
    ignores = {
      type = types.listOf types.str;
      default = [];
    };
    settings = {
      type = types.attrs;
      default = {};
    };
    signing = {
      type = (types.struct "signing" {
        format = types.option (
          types.enum "signingFormat" [
            "openpgp"
            "ssh"
            "x509"
          ]
        );
        key = types.str;
        signByDefault = types.bool;
        signer = types.str;
      }).override {total = false;};
      default = {};
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs) pkgs lib;
    inherit (pkgs) symlinkJoin makeWrapper linkFarm writeText;
    inherit (lib.generators) toGitINI;
    inherit (lib) concatStringsSep;

    iniConfig = lib.foldl' lib.recursiveUpdate {} [
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
          ${options.signing.format}.program =
            if (options.signing ? signer)
            then lib.getExe options.signing.signer
            else lib.getExe pkgs.gnupg;
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
      buildInputs = [makeWrapper];
      postBuild =
        /*
        bash
        */
        ''
          wrapProgram $out/bin/git \
          	--set XDG_CONFIG_HOME $out
        '';
      meta.mainProgram = "git";
    };
}
