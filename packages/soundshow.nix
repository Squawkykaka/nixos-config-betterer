{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  unzip,
  breakpointHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "soundshow";
  version = "2026.02.05";

  src = fetchFromGitHub {
    owner = "soundshow-app";
    repo = "soundshow-downloads";
    tag = "v${finalAttrs.version}";
    hash = "sha256-joJI0ggML+KtcOpozKYIVD8EJYk70lAJm7UlGMJsEiA=";
  };

  nativeBuildInputs = [
    unzip
  ];

  meta = {
    description = "Download Sound Show Releases";
    homepage = "https://github.com/soundshow-app/soundshow-downloads";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "soundshow";
    platforms = lib.platforms.all;
  };
})
