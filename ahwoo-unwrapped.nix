{
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  fetchurl,
  makeBinaryWrapper,
  libgcc,
  fontconfig,
  vulkan-loader,
  vulkan-validation-layers,
  dotnet-runtime_10,
  libpulseaudio,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  version = "latest";
  pname = "ahwoo";
  src = fetchurl {
    name = "ahwoo.tar.gz";
    url = "https://neutrino.ahwoo.com/download/linux";
    hash = "sha256-USbNhzdCkbl6Puu1OBbE9K73O1fp9u/hZgAb4zB4mEQ=";
  };
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  buildInputs = [
    libgcc
    fontconfig.lib

    vulkan-loader
    vulkan-validation-layers
    libpulseaudio
    dotnet-runtime_10
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/ahwoo $out/share/applications
    cp -a * $out/share/ahwoo
    chmod +x $out/share/ahwoo/ahwoo
    chmod +x $out/share/ahwoo/Service/ahwoo_service

    # BRUTAL does not support wayland fully currently.
    # vulkan and dotnet get passed down to ahwoo_client
    makeBinaryWrapper "$out/share/ahwoo/ahwoo" "$out/bin/ahwoo" \
      --unset WAYLAND_DISPLAY \
      --unset WAYLAND_SOCKET \
      --set XDG_SESSION_TYPE "x11" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}" \
      --prefix VK_LAYER_PATH : "${vulkan-validation-layers}/share/vulkan/explicit_layer.d" \
      --prefix PATH : "${dotnet-runtime_10}" \
      --set DOTNET_ROOT "${dotnet-runtime_10}/share/dotnet" \
      --set DOTNET_ROOT_X64 "${dotnet-runtime_10}/share/dotnet" \
      --chdir $out/share/ahwoo

    cat >> $out/share/applications/ahwoo.desktop<<EOF
    [Desktop Entry]
    Type=application
    Version=1.0
    Name=Ahwoo
    GenericName=Game Launcher
    Icon=ahwoo
    Exec=ahwoo
    Terminal=false
    Catagories=Game;LauncherStore
    EOF

    chmod 744 $out/share/applications/ahwoo.desktop
  '';

  strictDeps = true;
  __structuredAttrs = true;
})
