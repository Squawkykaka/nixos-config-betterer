{
  lib,
  stdenv,
  makeDesktopItem,
  wineWow64Packages,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "Voices of the Void";
  version = "0.9.0b_0004";
  src = ./setup_ksa_v2025.11.11.2924.exe;
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    echo -e "#!${stdenv.shell}\n\n${lib.getExe wineWow64Packages.waylandFull}  $out/VotV.exe" > ./votv
    chmod +x ./votv

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r WindowsNoEditor/* $out/
    mkdir -p $out/bin
    cp ./votv $out/bin/votv

    runHook postInstall
  '';

  desktopEntries = [
    (makeDesktopItem {
      name = "Voices of the Void";
      desktopName = "Voices of the Void";
      icon = fetchurl {
        url = "https://votv.dev/assets/body/logo.png";
        hash = "sha256-pEv5DMgCjNNXBvsNf8/hPiFMPeR0fz5OXLsOcBDWWao=";
      };
      exec = "votv";
      categories = [ "Game" ];
    })
  ];

  meta = {
    homepage = "https://votv.dev/";
    maintainers = with lib.maintainers; [ notarin ];
    platforms = lib.platforms.linux;
    mainProgram = "votv";
  };
}
