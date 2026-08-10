{
  sway-unwrapped,
  glslang,
  lcms,
  hwdata,
  libliftoff,
  lua54Packages,
  vulkan-loader,
  xwayland,
  seatd,
  libdisplay-info,
  libxcb-render-util,
  libxcb-errors,
  libgbm,
  readline,
  fetchFromGitHub,
  ...
}:
sway-unwrapped.overrideAttrs (old: {
  version = "1.12.18";
  src = fetchFromGitHub {
    owner = "dawsers";
    repo = "scroll";
    tag = "1.12.18";
    hash = "sha256-V6Aitjbm3GSB1+EAnoZ1kBzNV0olxV63B93S2qrWYos=";
  };

  mesonFlags = old.mesonFlags ++ [
    "-Dc_args=-Wno-error=maybe-uninitialized"
  ];

  passthru.providedSessions = [ "scroll" ];
  patches = [ ];

  nativeBuildInputs = old.nativeBuildInputs ++ [
    glslang
    lcms
    hwdata
    libliftoff
  ];

  buildInputs = old.buildInputs ++ [
    lua54Packages.lua
    vulkan-loader
    xwayland
    seatd
    lcms
    libdisplay-info
    libxcb-render-util
    libxcb-errors
    libliftoff
    libgbm
    readline
  ];

  meta.mainProgram = "scroll";
})
