{
  lib,
  python3,
  fetchFromGitHub,
  ...
}:
python3.pkgs.buildPythonPackage rec {
  pname = "tokenstream";
  version = "1.7.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "vberlier";
    repo = "tokenstream";
    rev = "v${version}";
    hash = "sha256-idTgTVaZkF6M9ly5HzqmHtUUc7Bp5VrR2EioDSHmThM="; # Replace with the actual hash
  };

  nativeBuildInputs = [python3.pkgs.poetry-core];

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  meta = with lib; {
    description = "A versatile token stream for handwritten parsers";
    homepage = "https://github.com/vberlier/tokenstream";
    license = licenses.mit;
    maintainers = [];
  };
}
