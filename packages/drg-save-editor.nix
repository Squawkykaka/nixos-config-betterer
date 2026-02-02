{
  python3Packages,
  fetchFromGitHub,
  ...
}:
python3Packages.buildPythonPackage rec {
  pname = "drg-save-editor";
  version = "1.10.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "AnthonyMichaelTDM";
    repo = "DRG-Save-Editor";
    tag = "v${version}";
    hash = "sha256-8dOR3KHN1nI/lmmSvvpKXbHVnN6v1eLHoi0CoIt5Lf4=";
  };

}
