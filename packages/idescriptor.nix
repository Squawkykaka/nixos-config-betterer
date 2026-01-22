{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  lxqt,
  libimobiledevice,
  qrencode,
  libheif,
  libzip,
  ffmpeg,
  libirecovery,
  libssh,
  pugixml,
  libusb1,
  avahi,
  avahi-compat,
  libsysprof-capture,
  libunwind,
  elfutils,
  orc,
  buildGoModule,
  ...
}:
let
  ipatool-go = buildGoModule {
    pname = "ipatool-go";
    version = "6872f99";

    src = fetchFromGitHub {
      owner = "uncor3";
      repo = "libipatool-go";
      rev = "6872f99";
      hash = "sha256-mGGFu0tc07bivLhTi4X8k24ZtwE1vJ/W/CuhfoXZxUk=";
    };

    vendorHash = "sha256-dR988pY3HfRmQhwtOynCw9g/ldbVZHhyB5FoHsNmObQ=";

    doCheck = false;

    buildPhase = ''
      mkdir -p $out/lib
      mkdir -p $out/include

      # Build the Go static library
      go build -buildmode=c-archive -o $out/lib/libipatool-go.a main.go
      mv $out/lib/libipatool-go.h $out/include/libipatool-go.h
    '';
    meta = {
      mainProgram = "ipatool";
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "idescriptor";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "iDescriptor";
    repo = "iDescriptor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pj/8PCZUTPu28MQd3zL8ceDsQy4+55348ZOCpiQaiEo=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "add_subdirectory(lib/ipatool-go)" ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  cmakeFlags = [
    "-DIPATOOL_GO_INCLUDE_DIR=${ipatool-go}/include"
    "-DIPATOOL_GO_LIB=${ipatool-go}/lib/libipatool-go.a"
  ];

  postInstall = ''
    mkdir -p $out/etc/udev/rules.d/
    echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", MODE="0666"' > $out/etc/udev/rules.d/99-idevice.rules
  '';

  buildInputs = [
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtserialport
    qt6.qtpositioning
    qt6.qtlocation
    lxqt.qtermwidget
    libimobiledevice
    qrencode
    libzip
    libheif
    ffmpeg
    libirecovery
    libssh
    pugixml
    libusb1
    avahi
    avahi-compat
    libsysprof-capture
    libunwind
    elfutils
    orc
    ipatool-go
  ];

  meta = {
    homepage = "https://github.com/iDescriptor/iDescriptor";
    description = " A free, open-source, and cross-platform iDevice management tool.";
    # maintainers = with lib.maintainers; [ notarin ];
    platforms = lib.platforms.linux;
    mainProgram = "iDescriptor";
  };
})
