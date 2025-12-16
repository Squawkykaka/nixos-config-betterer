{
  python3Packages,
  fetchPypi,
  fetchurl,
  ...
}: let
  dacite = python3Packages.dacite.overridePythonAttrs (_: {
    version = "1.9.2";
    src = fetchPypi {
      pname = "dacite";
      version = "1.9.2";
      hash = "sha256-bMw7KZcnx6oXWC8AIfauFNXeR8cieTLEf+xM3+/Sbwk=";
    };

    doCheck = false;
  });

  mako = python3Packages.mako.overridePythonAttrs (_: {
    version = "1.3.10";

    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/9e/38/bd5b78a920a64d708fe6bc8e0a2c075e1389d53bef8413725c63ba041535/mako-1.3.10.tar.gz";
      hash = "sha256-mVeabzlYP6flYwoow8H0QOTpekFLgDcmScDOM42i6ig=";
    };

    doCheck = false;
  });

  typer = python3Packages.typer.overridePythonAttrs (_: {
    version = "0.16.0";
    src = fetchPypi {
      pname = "typer";
      version = "0.16.0";
      hash = "sha256-rzd/+u4dvjeulEDLTo8RaG6lzk6brgG4SufGO4fx3Ts=";
    };

    doCheck = false;
  });
in
  python3Packages.buildPythonPackage rec {
    pname = "zmk";
    version = "0.3.2";
    pyproject = true;

    build-system = [
      python3Packages.setuptools
      python3Packages.setuptools-scm
    ];

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-zhjAfzr0Yz3ZsW2liYI9rTNcxCOdCftWT2Z4xrvlDt4=";
    };

    propagatedBuildInputs = with python3Packages;
      [
        shellingham
        west
        rich
        ruamel-yaml
      ]
      ++ [
        dacite
        mako
        typer
      ];
  }
