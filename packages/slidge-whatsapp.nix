{
  python3,
  fetchPypi,
  fetchFromGitHub,
  fetchFromCodeberg,
  slidge,
}:
let
  python = python3.override {
    self = python;

    packageOverrides = prev: super: {
      slidge = slidge;

      pillow = super.pillow.overridePythonAttrs (_: {
        version = "11.3.0";
        src = super.fetchPypi {
          pname = "pillow";
          version = "11.3.0";
          hash = "sha256-OCjudYbNCyCRtiCeWtU+INBkm76HFkpFnQZ24DXo9SM=";
        };
      });

      linkpreview = prev.buildPythonPackage rec {
        pname = "linkpreview";
        version = "0.12.0";
        pyproject = true;

        src = fetchPypi {
          inherit pname version;
          hash = "sha256-6xT38DLvgAlbP+kIpFrIGIPLEal8dmgfMjNg5vEC5nU=";
        };

        build-system = with python.pkgs; [
          setuptools
          setuptools-scm
        ];

        dependencies = with python.pkgs; [
          requests
          beautifulsoup4
        ];
      };
    };
  };
in
python.pkgs.buildPythonPackage rec {
  pname = "slidge-whatsapp";
  version = "0.3.10";
  pyproject = true;

  src = fetchFromCodeberg {
    owner = "slidge";
    repo = "slidge-whatsapp";
    tag = "v${version}";
    hash = "sha256-Sb0pn1FHpqBfcZGQ4rlgdIDgJdKAPmI5TbG9KoVcpSU=";
  };

  build-system = with python.pkgs; [
    poetry-core
    pybindgen
    packaging
    poetry-dynamic-versioning
  ];

  dependencies = with python.pkgs; [
    slidge
    linkpreview
  ];

  buildInputs = [ ];
}
