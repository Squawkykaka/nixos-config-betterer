{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nitrolaunch-cli";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "Nitrolaunch";
    repo = "nitrolaunch";
    rev = version;
    hash = "sha256-eWBD9bzN5aAo5xE4MUIsbkBDl800gR6EGw4PSMRwBVA=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  cargoBuildFlags = [
    "--package"
    "nitro_cli"
  ];

  meta = with lib; {
    description = "A fast, extensible, and powerful Minecraft launcher";
    homepage = "https://github.com/Nitrolaunch/nitrolaunch";
    license = licenses.gpl3;
    mainProgram = "nitro";
    maintainers = [];
  };
}
