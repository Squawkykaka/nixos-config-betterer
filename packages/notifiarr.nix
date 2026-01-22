{
  lib,
  buildNpmPackage,
  importNpmLock,
  fetchzip,
  buildGoModule,
}:
let
  # src = fetchFromGitHub {
  #   owner = "Notifiarr";
  #   repo = "notifiarr";
  #   rev = "v0.9.1";
  #   sha256 = "sha256-4vWTC25FoqeL43wjJ/b1MmDEGlAbiivVHA3zHnWoH4g=";
  # };
  src = fetchzip {
    url = "https://github.com/Notifiarr/notifiarr/releases/download/v0.9.1/notifiarr-0.9.1-2901-x86_64.pkg.tar.zst";
  };

  frontend = buildNpmPackage {
    pname = "notifiarr-frontend";
    version = "0.9.1";

    npmDeps = importNpmLock { npmRoot = "${src}/frontend"; };

    inherit src;

    # Svelte/Vite outputs to dist/
    # npmDepsHash = "";

    installPhase = ''
      mkdir -p $out
      cp -r dist $out/dist
    '';
  };
in
buildGoModule (finalAttrs: {
  pname = "notifiarr";
  version = "0.9.1";

  inherit src;

  vendorHash = "sha256-RJTLud3HLk+pvfKaR2HyhXsBvEOdeX0DotjylX70pv4=";

  preBuild = ''
    echo "Copying frontend dist to frontend/dist"
    rm -rf frontend/dist
    cp -r ${frontend}/dist frontend/dist
  '';

  subPackages = [ "." ];

  meta = with lib; {
    description = "Notifiarr automation & notification daemon";
    homepage = "https://github.com/Notifiarr/notifiarr";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.unix;
  };
})
