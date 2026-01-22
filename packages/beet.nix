{
  lib,
  python3,
  fetchFromGitHub,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "mcbeet";
  version = "0.111.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "mcbeet";
    repo = "beet";
    rev = "v${version}";
    hash = "sha256-cZG5HKHVAUh+oTb+ULPBWyqXrdgvTTbYTyqewYGcxWQ=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    (nbtlib.overrideAttrs (old: {
      version = "1.12.1";
      src = fetchFromGitHub {
        owner = "vberlier";
        repo = "nbtlib";
        rev = "v1.12.1";
        hash = "sha256-fvaJXVSwkOc2FM2x9cXf4b9CHbggDJlQNCfSruYL2Wo=";
      };
    }))
    (pathspec.overrideAttrs (old: {
      version = "0.11.2";
      src = fetchPypi {
        pname = "pathspec";
        version = "0.11.2";
        sha256 = "sha256-4NjQrC8S2mGVbrIwa2n5RptC9N6w88tu1HuczpmWztM=";
      };
    }))
    pydantic
    click
    click-help-colors
    poetry-core
    jinja2
    toml
    pyyaml
    pillow
    colorama
    typing-extensions
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-quiet 'build-backend = "poetry.masonry.api"' 'build-backend = "poetry.core.masonry.api"' \
      --replace-quiet 'requires = ["poetry>=0.12"]' 'requires = ["poetry-core>=1.0.0"]'
  '';

  meta = with lib; {
    description = "Minecraft pack development kit";
    longDescription = ''
      Beet is a build tool and development kit for Minecraft resource packs and data packs.
      It offers a plugin-based pipeline and Python API for authoring and transforming Minecraft content efficiently.
    '';
    homepage = "https://mcbeet.dev/";
    changelog = "https://github.com/mcbeet/beet/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "beet";
  };
}
