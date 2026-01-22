{
  lib,
  fetchurl,
  stdenv,
  makeDesktopItem,
  p7zip,
  wine,
  ...
}:
let
  files = {
    fusion360 = fetchurl {
      url = "https://dl.appstreaming.autodesk.com/production/installers/Fusion%20Admin%20Install.exe";
      hash = "sha256-kqOBfLGn6wsOC0nsVYz0IXUTGnKFZQzORxIjRrW2pvI=";
      # dontUnpack = true;
    };
    webview2 = fetchurl {
      url = "https://github.com/aedancullen/webview2-evergreen-standalone-installer-archive/releases/download/109.0.1518.78/MicrosoftEdgeWebView2RuntimeInstallerX64.exe";
      hash = "";
      # dontUnpack = true;
    };
    qt6webengine = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/Qt6WebEngineCore-06-2025.7z";
      hash = "";
      buildInputs = [ p7zip ];
    };
    siapDll = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/extras/patched-dlls/siappdll.dll";
      hash = "";
      # dontUnpack = true;
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "Fusion360";
  version = "2605.1.52";
  src = null;
  dontUnpack = true;

  buildInputs = [ wine ];

  buildPhase = ''
    mkdir -p $out
    runHook preBuild
    export WINEPREFIX=$out/wineprefix
    export HOME=$out/.cache

    timeout -k 10m 9m wine ${files.fusion360} --quiet
    sleep 5s
    timeout -k 5m 1m wine ${files.fusion360} --quiet


    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    mkdir -p $out/bin
    mkdir -p $out/share/

    ls $desktopItem/share/applications
    ln -s "$desktopItem/share/applications" $out/share/

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    name = "Autodesk Fusion";
    desktopName = finalAttrs.pname;
    icon = fetchurl {
      url = "https://raw.githubusercontent.com/cryinkfly/Autodesk-Fusion-360-for-Linux/main/files/setup/resource/graphics/autodesk_fusion.svg";
      hash = "sha256-YSz+4mWksZbut/gv4dt7d6MjsKhqNgWU2rbO2KmixOw=";
    };
    exec = finalAttrs.meta.mainProgram;
    categories = [
      "Education"
      "Engineering"
      "Graphics"
      "Science"
    ];
    keywords = [ finalAttrs.meta.mainProgram ];
    # singleMainWindow = true;
  };
  meta = {
    homepage = "https://www.autodesk.com/products/fusion-360";
    description = "Autodesk Fusion 360 is a cloud-based CAD software platform for product design and manufacturing.";
    # maintainers = with lib.maintainers; [ notarin ];
    platforms = lib.platforms.linux;
    mainProgram = "Fusion360";
  };
})
