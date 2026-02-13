{
  breakpointHook,
  lib,
  stdenv,
  git,
  fetchFromGitHub,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pyrodactyl";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "pyrohost";
    repo = "pyrodactyl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C/3FtPpGwPEGqwf96sWxu/tzfjR5r3z6yzYK38fO8hA=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-CynpNHr6k4GbMZ2/lW+MoWTb14ERW17Quwum7v5x16E=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    breakpointHook
  ];

  buildInputs = [
    git
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run ship
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{assets,build}
    cp -r public/assets/* $out/assets
    cp -r public/build/* $out/build
    runHook postInstall
  '';
})
