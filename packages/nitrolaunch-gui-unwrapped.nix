{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeDesktopItem,
  pkg-config,
  openssl,
  libsoup_3,
  gtk3,
  webkitgtk_4_1,
  cargo-tauri,
  glib-networking,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  makeWrapper,
  wrapGAppsHook3,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nitrolaunch";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "Nitrolaunch";
    repo = finalAttrs.pname;
    # rev = finalAttrs.version;
    rev = "e7153bd";
    hash = "sha256-HaamJ0WwAdwVV2WMQLTsQ9buEEH05WqRWwlLvagRZ5o=";
  };

  # Needed as nitro_gui is in a cargo workspace
  postPatch = ''
    ln -s $NIX_BUILD_TOP/source/Cargo.lock gui/src-tauri/Cargo.lock

    substituteInPlace gui/src-tauri/tauri.conf.json \
       --replace-fail '"createUpdaterArtifacts": "v1Compatible"' '"createUpdaterArtifacts": false'
  '';

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    src = "${finalAttrs.src}/${finalAttrs.npmRoot}";
    lockFile = "package-lock.json";
    hash = "sha256-Xw0gl/SVUUiWH2r30kwqZ8Y0mH6uQ1RSZ4J0ngcbP1E=";
  };

  npmRoot = "gui";

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    wrapGAppsHook3
    makeWrapper
  ];

  buildInputs = [
    glib-networking
    openssl
    libsoup_3
    gtk3
    webkitgtk_4_1
  ];

  cargoRoot = "gui/src-tauri";
  buildAndTestSubdir = "gui/src-tauri";

  desktopItems = [
    (makeDesktopItem {
      name = "Nitrolaunch";
      exec = "nitrolaunch";
      icon = "nitrolaunch";
      desktopName = "Nitrolaunch";
      comment = "A fast, extensible, and powerful Minecraft launcher";
      categories = [
        "Game"
        "Utility"
      ];
    })
  ];

  meta = with lib; {
    description = "A fast, extensible, and powerful Minecraft launcher";
    homepage = "https://github.com/Nitrolaunch/nitrolaunch";
    license = licenses.gpl3;
    mainProgram = "Nitrolaunch";
    maintainers = [];
  };
})
