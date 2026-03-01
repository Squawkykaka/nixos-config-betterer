{
  slidge,
  python3,
  fetchFromCodeberg,
  fetchFromGitHub,
}:
let
  python = python3.override {
    self = python;

    packageOverrides = prev: super: {
      discord_protos = prev.buildPythonPackage rec {
        pname = "discord_protos";
        version = "latest";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "discord-userdoccers";
          repo = "discord-protos";
          rev = "895f2ff26c35799cd5f770822aaa2a5817edd4e7";
          hash = "sha256-HO5SyTm3j6l8n1/ghULEFVXnvk+CPYMjoY59J05dJeM=";
        };

        build-system = with python.pkgs; [
          setuptools
          wheel
        ];

        dependencies = with python.pkgs; [ protobuf ];
      };
      slidge = slidge;
      pillow = super.pillow.overridePythonAttrs (_: {
        version = "11.3.0";
        src = super.fetchPypi {
          pname = "pillow";
          version = "11.3.0";
          hash = "sha256-OCjudYbNCyCRtiCeWtU+INBkm76HFkpFnQZ24DXo9SM=";
        };
      });
      discord-py-self = prev.buildPythonPackage rec {
        pname = "discord-py-self";
        version = "2.1.0";
        pyproject = true;

        src = fetchFromGitHub {
          owner = "dolfies";
          repo = "discord.py-self";
          tag = "v${version}";
          hash = "sha256-jVz3uGU+4E5Awbk6ZYAsXvEpClNHm2QN1RpBTIiQTpE=";
        };

        build-system = with python.pkgs; [
          setuptools
          setuptools-scm
        ];

        dependencies = with python.pkgs; [
          aiohttp
          curl-cffi
          tzlocal
          discord_protos
          audioop-lts
        ];

      };
    };
  };
in
python.pkgs.buildPythonPackage rec {
  pname = "slidcord";
  version = "0.3.1";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "slidge";
    repo = "slidcord";
    tag = "v${version}";
    hash = "sha256-INgStitrOiRxbweK29Hrp2NEIFf+1FlwulrMB+KwKRo=";
  };

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python.pkgs; [
    slidge
    emoji
    discord-py-self
  ];
}
