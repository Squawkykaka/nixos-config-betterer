{
  lib,
  python3,
  fetchFromGitHub,
  beet,
  mecha,
  ...
}:
python3.pkgs.buildPythonPackage rec {
  pname = "mcbolt";
  version = "0.49.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "mcbeet";
    repo = "bolt";
    rev = "v${version}";
    hash = "sha256-kJgZVwMZ1Z50KSYFA16SF3zMpGgYbX3ryFgYTso+JUM=";
  };

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  # Poetry dependencies
  propagatedBuildInputs = [
    beet
    mecha
  ];

  # Add plugins if needed (e.g., for Beet)
  meta = with lib; {
    description = "Supercharge Minecraft commands with Python";
    homepage = "https://github.com/mcbeet/bolt";
    license = licenses.mit;
    maintainers = [ ];
  };
}
