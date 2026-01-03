{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nitrolaunch-cli";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "Nitrolaunch";
    repo = "nitrolaunch";
    rev = version;
    hash = "sha256-QnmC8BmMKr7M206Np6Dafe8T04iZGIbkY4Lzj3TlUyE=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  buildType = "fast_release";

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
