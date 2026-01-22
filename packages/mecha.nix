{
  lib,
  python3,
  fetchFromGitHub,
  tokenstream,
  beet,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "mecha";
  version = "0.98.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "mcbeet";
    repo = "mecha";
    rev = "v${version}";
    hash = "sha256-+3yVO9cdIyhUvXXJWwONbqD0b7juPW0YMfz1pLbXZQI="; # Replace this!
  };

  propagatedBuildInputs = [
    beet
    tokenstream
  ];

  nativeBuildInputs = [ python3.pkgs.poetry-core ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-quiet 'build-backend = "poetry.masonry.api"' 'build-backend = "poetry.core.masonry.api"' \
      --replace-quiet 'requires = ["poetry>=0.12"]' 'requires = ["poetry-core>=1.0.0"]'
  '';

  pythonImportsCheck = [ "mecha" ];

  meta = with lib; {
    mainProgram = "mecha";
    description = "A powerful Minecraft command library";
    homepage = "https://github.com/mcbeet/mecha";
    license = licenses.mit;
    maintainers = [ ];
  };
}
