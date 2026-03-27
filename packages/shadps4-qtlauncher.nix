{
  lib,
  stdenv,
  fetchFromGitHub,
  qt6,
  git,
  pkg-config,
  wayland-protocols,
  libpng,
  vulkan-headers,
  vulkan-utility-libraries,
  vulkan-tools,

  ffmpeg,
  glslang,
  libxkbcommon,
  wayland,
  libxcb,
  xcbutil,
  xcbutilkeysyms,
  xcbutilwm,
  stb,
  alsa-lib,
  libpulseaudio,
  openal,
  openssl,
  zlib,
  libedit,
  udev,
  libevdev,
  jack2,
  sndio,
  fmt,
  sdl3,
  toml11,
  cmake,
  nlohmann_json,
  volk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shadps4-qtlauncher";
  version = "224";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadps4-qtlauncher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0tDfiYYFYt8sq4fO4tkA60Kjci8/Cxyh9gKKk9/Ngqs=";
  };

  postPatch = ''
    sed -i '/add_subdirectory/d' externals/CMakeLists.txt

    sed -i '1i find_package(nlohmann_json REQUIRED)' CMakeLists.txt
    sed -i '1i include_directories(${volk}/include)' CMakeLists.txt
  '';

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
    git
  ];

  buildInputs = [
    fmt
    toml11
    alsa-lib
    libpulseaudio
    openal
    openssl
    zlib
    libedit
    udev
    libevdev
    jack2
    sndio
    qt6.qtbase
    qt6.qttools
    qt6.qtmultimedia

    vulkan-headers
    vulkan-utility-libraries
    vulkan-tools

    sdl3
    ffmpeg
    glslang
    libxkbcommon
    wayland
    libxcb
    xcbutil
    xcbutilkeysyms
    xcbutilwm
    stb
    qt6.qtwayland
    wayland-protocols
    libpng

    nlohmann_json
    volk
  ];

  meta = {
    description = "The official Qt launcher for shadps4 emulator";
    homepage = "https://github.com/shadps4-emu/shadps4-qtlauncher";
    license = with lib.licenses; [
      gpl2Only
      boost
      gpl2Plus
      mit
    ];
    maintainers = with lib.maintainers; [ ];
    mainProgram = "shadps4-qtlauncher";
    platforms = lib.platforms.all;
  };
})
