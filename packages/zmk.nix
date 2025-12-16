{
  python3Packages,
  fetchPypi,
  ...
}:
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

  propagatedBuildInputs = with python3Packages; [
    shellingham
    typer
    west
    dacite
    mako
    rich
    ruamel-yaml
  ];
}
