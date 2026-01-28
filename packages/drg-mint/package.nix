{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  wrapGAppsHook3,
  glib,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "drg-mint";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iVDSQ/TyxrgNmJYwK/UgZCU/iUOeYrHyBaqcXgvkCnY=";
  };

  cargoHash = "sha256-qykL79U1Q7CgPWNf2nux3e1+xzqbFV5gUS4vJdgq1uA=";

  cargoPatches = [
    ./1-fix-windows-build.patch
  ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    glib
  ];
})
