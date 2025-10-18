{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeDesktopItem,
  pkg-config,
  openssl,
  libsoup_2_4,
  gtk3,
  webkitgtk_4_0,
  cargo-tauri_1,
  glib-networking,
  nodejs,
  npmHooks,
  fetchNpmDeps,
  makeWrapper,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nitrolaunch";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "Nitrolaunch";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-eWBD9bzN5aAo5xE4MUIsbkBDl800gR6EGw4PSMRwBVA=";
  };

  # cargoBuildFlags = [
  #   "--package"
  #   "nitro_gui"
  # ];

  postPatch = ''ln -s $NIX_BUILD_TOP/source/Cargo.lock gui/src-tauri/Cargo.lock'';

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    src = "${finalAttrs.src}/${finalAttrs.npmRoot}";
    lockFile = "package-lock.json";
    hash = "sha256-vdpVoMpQ0DRDe8ubDtP4hIK8ULVMhy1SDJHeL1yY0ao=";
  };

  npmRoot = "gui";

  nativeBuildInputs = [
    cargo-tauri_1.hook
    nodejs
    npmHooks.npmConfigHook
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    glib-networking
    openssl
    libsoup_2_4
    gtk3
    webkitgtk_4_0
  ];

  # This tells the builder where the Cargo.toml is
  cargoRoot = "gui/src-tauri";
  buildAndTestSubdir = "gui/src-tauri";

  postInstall = ''
    wrapProgram $out/bin/nitrolaunch \
      --set __NV_DISABLE_EXPLICIT_SYNC 1
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Nitrolaunch";
      exec = "nitro";
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
    mainProgram = "nitrolaunch";
    maintainers = [];
  };
})
