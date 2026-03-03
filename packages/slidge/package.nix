{
  python3,
  fetchPypi,
}:
let
  python = python3.override {
    self = python;

    packageOverrides = prev: super: {
      pillow = super.pillow.overridePythonAttrs (_: {
        version = "11.3.0";
        src = super.fetchPypi {
          pname = "pillow";
          version = "11.3.0";
          hash = "sha256-OCjudYbNCyCRtiCeWtU+INBkm76HFkpFnQZ24DXo9SM=";
        };
      });

      thumbhash = prev.buildPythonPackage rec {
        pname = "thumbhash";
        version = "0.1.2";
        pyproject = true;

        src = fetchPypi {
          inherit version pname;
          hash = "sha256-705jmPk/O1rUgNyOOjs6IAgTyGqIV/sGn4R4voCfgkc=";
        };

        build-system = with python.pkgs; [ hatchling ];
      };

      slixmpp = super.slixmpp.overridePythonAttrs (old: rec {
        version = "1.12.0";
        src = old.src.override {
          inherit version;
          hash = "sha256-hjM1OIFYpHV5SSN32858pyuwOvaAA0tFZWCZI+5n9u4=";
        };
      });
    };
  };
in
python.pkgs.buildPythonPackage rec {
  pname = "slidge";
  version = "0.3.6";
  pyproject = true;

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-MUDSx7RRg3duzvimzTxVbLUjkexx5Am2O0m9W0pIAFk=";
  };

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python.pkgs; [
    aiohttp
    alembic
    configargparse
    defusedxml
    pillow
    python-magic
    qrcode
    slixmpp
    sqlalchemy
    thumbhash
  ];
}
