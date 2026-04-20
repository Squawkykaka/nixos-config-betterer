{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gtk2,
  cairo,
  pango,
  gdk-pixbuf,
}:
stdenv.mkDerivation {
  pname = "axepad";
  version = "1.5.1";
  src = fetchurl {
    url = "https://picaxe.com/downloads/linaxepad.tar.gz";
    hash = "sha256-pNn8FBdW02yCAjN05txwW4bpIHBH0tL2KKgcglQPez4=";
  };
  unpackPhase = ''
    mkdir source
    tar -xzf $src -C source
    export sourceRoot=source
  '';
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    gtk2
    cairo
    pango
    gdk-pixbuf
  ];
}
