{buildFHSEnv}:
buildFHSEnv {
  name = "nitrolaunch-gui";
  targetPkgs = pkgs: [
    pkgs.nitrolaunch-gui-unwrapped

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

  runScript = "/bin/Nitrolaunch";
}
