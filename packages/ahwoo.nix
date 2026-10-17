{
  buildFHSEnv,
  ahwoo-unwrapped,
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
    ++ [ ahwoo-unwrapped ];

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${ahwoo-unwrapped}/share/applications/ahwoo.desktop $out/share/applications/
  '';

  runScript = "ahwoo";
}
