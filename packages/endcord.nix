{
  lib,
  fetchFromGitHub,
  python3Packages,
  python3,
  fetchPypi,
  rustPlatform,
  makeWrapper,
  ...
}: let
  numpy_2_4_0 = python3Packages.numpy.overrideAttrs (old: rec {
    version = "2.4.0";

    src = python3Packages.fetchPypi {
      pname = "numpy";
      inherit version;
      hash = "sha256-blBPexYRgZjxOO8xuiTZhbEkwsRp/oRnAHzzD9mS+TQ=";
    };

    # numpy uses meson now
    nativeBuildInputs =
      old.nativeBuildInputs
      ++ [
        python3Packages.meson-python
      ];
  });

  orjson_3_11_5 = python3Packages.orjson.overrideAttrs (old: rec {
    pname = "orjson";
    version = "3.11.5";

    src = fetchFromGitHub {
      owner = "ijl";
      repo = "orjson";
      tag = version;
      hash = "sha256-MWNAP8p4TN5yXFtXKWCyguv3EnFpZHMG8YEIiFF1Vug="; # replace with correct hash
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit pname version src;
      hash = "sha256-sRVa1cCbZQJq4bASn7oreEKpzTvuDoMzVs/IbojQa8s="; # replace with correct hash
    };
  });

  python-socks_2_8_0 = python3Packages.python-socks.overrideAttrs (old: rec {
    version = "2.8.0";

    src = fetchFromGitHub {
      owner = "romis2012";
      repo = "python-socks";
      tag = "v${version}";
      hash = "sha256-b19DfvoJo/9NCjgZ+07WdZGnXNS7/f+FgGdU8s1k2io=";
    };
  });

  urllib3_2_6_2 = python3Packages.urllib3.overrideAttrs (old: rec {
    version = "2.6.2";

    src = fetchPypi {
      pname = old.pname;
      inherit version;
      hash = "sha256-AW+cmLt+mAhcsrSxe4fSxwKXVmTk8GDGUy5k0cGl55c=";
    };

    postPatch = null;
  });

  websocket-client_1_9_0 = python3Packages.websocket-client.overrideAttrs (old: rec {
    version = "1.9.0";

    src = fetchPypi {
      pname = "websocket_client";
      inherit version;
      hash = "sha256-noE2JLbrYZmZqX3HlYRpIXwxdjErOhakvRvH4IpG7Jg=";
    };
  });

  discord-protos = python3Packages.buildPythonPackage rec {
    pname = "discord-protos";
    version = "0.0.2";
    pyproject = true;

    build-system = with python3Packages; [setuptools setuptools-scm protobuf];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-I5U6BfMr7ttAtwjsS0V1MKYZaknI110zeukoKipByZc=";
    };
  };
in
  python3Packages.buildPythonApplication rec {
    pname = "endcord";
    version = "1.1.6";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "sparklost";
      repo = "endcord";
      rev = version;
      hash = "sha256-eD4ZNziMDJiX5AlpLXIxbmjCjFF/5v/pX6M9hJLpSxQ=";
    };

    nativeBuildInputs = [makeWrapper];
    build-system = [
      python3Packages.setuptools
      python3Packages.setuptools-scm
      python3Packages.cython
      numpy_2_4_0
    ];

    propagatedBuildInputs =
      [
        orjson_3_11_5
        python-socks_2_8_0
        urllib3_2_6_2
        websocket-client_1_9_0
        discord-protos
      ]
      ++ (with python3Packages; [setuptools emoji pexpect filetype pysocks soundcard soundfile]);

    postInstall = ''
      makeWrapper ${lib.getExe python3} $out/bin/endcord \
        --set PYTHONPATH "$PYTHONPATH" \
        --add-flags "-m endcord_cython"
    '';

    meta = {
      mainProgram = "endcord";
    };
  }
