{
  symlinkJoin,
  buildFHSEnv,
  nitrolaunch-gui,
  nitrolaunch-cli,
  lib,
}: let
  guiEnv = buildFHSEnv {
    name = "nitrolaunch-gui-${nitrolaunch-gui.version}";
    targetPkgs = pkgs: [
      nitrolaunch-gui
      pkgs.zulu24

      pkgs.openal

      pkgs.glfw3-minecraft
      pkgs.alsa-lib
      pkgs.libjack2
      pkgs.libpulseaudio
      pkgs.pipewire

      pkgs.libGL
      pkgs.xorg.libX11
      pkgs.xorg.libXcursor
      pkgs.xorg.libXext
      pkgs.xorg.libXrandr
      pkgs.xorg.libXxf86vm

      pkgs.udev

      pkgs.vulkan-loader
    ];
    runScript = "/bin/nitrolaunch";
  };
in
  symlinkJoin {
    name = "nitrolaunch";

    paths = [
      guiEnv
      nitrolaunch-cli
      guiEnv
    ];

    meta = with lib; {
      description = "A fast, extensible, and powerful Minecraft launcher";
      homepage = "https://github.com/Nitrolaunch/nitrolaunch";
      license = licenses.gpl3;
      maintainers = [];
      mainProgram = "nitrolaunch";
    };
  }
