{
  fetchFromGitHub,
  buildNpmPackage,
  version ? "2.31.0",
  ...
}:
let
  imgDrv = fetchFromGitHub {
    owner = "5etools-mirror-3";
    repo = "5etools-img";
    tag = "v${version}";
  };
  srcDrv = buildNpmPackage {
    pname = "5etools-src";
    version = "${version}";
    src = fetchFromGitHub {
      owner = "5etools-mirror-3";
      repo = "5etools-src";
      tag = "v${version}";
      hash = "sha256-mxXGcf/4n54WL8LFccNq0N3eajPU6An0s+XA990tl4I=";
    };
    npmDepsHash = "sha256-Vtvp9hplZl5FZp3cK9mnLKK42TVKxiU9AnqsM4JNd4w=";
    installPhase = ''
      mkdir -p $out
      cp -r . $out
    '';
  };
in
srcDrv
