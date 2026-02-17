{
  stdenv,
  callPackage,
}:
let
  frontend = callPackage ./frontend.nix { };
  backend = callPackage ./backend.nix { };
in
stdenv.mkDerivation {
  pname = "pyrodactyl";
  version = "4.5.0";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    # Copy entire backend as base
    mkdir -p $out/app
    cp -r ${backend}/* $out/app
    chmod -R 775 $out/app/public

    # Merge frontend assets into public directory
    mkdir -p $out/app/public/assets $out/app/public/build
    cp -r ${frontend}/assets/* $out/app/public/assets/
    cp -r ${frontend}/build/* $out/app/public/build/

    # Ensure proper permissions
    chmod -R 755 $out/app/bootstrap $out/app/storage $out/app/public
  '';
}
