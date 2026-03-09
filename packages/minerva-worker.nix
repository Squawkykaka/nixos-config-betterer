{
  lib,
  aria2,
  makeWrapper,
  symlinkJoin,
  python3,
  fetchFromGitHub,
}:
let
  python = python3.override {
    self = python;
    packageOverrides = prev: super: {
      rich = super.rich.overridePythonAttrs (old: rec {
        version = "14.3.3";
        src = old.src.override {
          inherit version;
          hash = "sha256-oQbxRbZnVr/Ln+i/hpBw5FlpUp3gcp/7xsxi6onPkn8=";
        };
      });

      pyjwt = super.pyjwt.overridePythonAttrs (old: rec {
        version = "2.11.0";
        src = old.src.override {
          inherit version;
          hash = "sha256-BPVythRLpglYtpLEoaC7+Q4l9izYXH2M9JEbxdyQZqU=";
        };
      });
    };
  };

  minerva-unwrapped = python.pkgs.buildPythonPackage rec {
    pname = "minerva-worker";
    version = "2.0.0";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "minerva-archive";
      repo = "worker";
      tag = "v${version}";
      hash = "sha256-ULIjAwVNwVi2WJNpOt3+PSoHeiNI0ZEBvfCQBBDIIv8=";
    };

    build-system = with python.pkgs; [ hatchling ];

    dependencies = with python.pkgs; [
      click
      rich
      httpx
      pathvalidate
      pyjwt
      humanize
      humanfriendly
      readchar
      websockets
    ];

    buildInputs = [ aria2 ];

    pythonRelaxDeps = [
      "rich"
      "pyjwt"
    ];

    meta = {
      description = "Minerva DPN Worker";
      homepage = "https://minerva-archive.org";
      license = lib.licenses.cc0;
      mainProgram = "minerva";
    };
  };
in
symlinkJoin {
  pname = "minerva-worker-wrapped";
  inherit (minerva-unwrapped) version meta;

  paths = [ minerva-unwrapped ];
  buildInputs = [ makeWrapper ];
  postBuild = /* bash */ ''
    wrapProgram $out/bin/minerva \
      --set PATH $PATH:${aria2}/bin
  '';
}
