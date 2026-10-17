{
  buildFHSEnv,
  ahwoo,
}:
buildFHSEnv {
  name = "ahwoo";
  targetPkgs =
    pkgs:
    with pkgs;
    [
      icu
      fontconfig
      zlib
      openssl
      libx11
      libxcursor
      libxinerama
      libxi
      libxrandr
      libGL
      libglvnd
      libxkbcommon
      libice
      libsm
      alsa-lib
    ]
    ++ [ ahwoo ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${ahwoo}/share/applications/ahwoo.desktop $out/share/applications/
  '';

  runScript = "ahwoo";
}
