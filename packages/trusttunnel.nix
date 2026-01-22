{
  libclang,
  fetchFromGitHub,
  rustPlatform,
  boringssl,
  runCommand,
}:
let
  boringssl-wrapper = runCommand "boringssl-wrapper" { } ''
    mkdir $out
    cd $out
    ln -s ${boringssl.out}/lib build
    ln -s ${boringssl.dev}/include include
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "trusttunnel";
  version = "0.9.109";

  src = fetchFromGitHub {
    owner = "TrustTunnel";
    repo = "TrustTunnel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-f6vzKIBy9XKov92sElBPdQsFqdzSQGCGzS+zC4lYbv4=";
  };

  env.BORING_BSSL_PATH = "${boringssl-wrapper}";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libclang
  ];

  cargoHash = "sha256-meiumPdqmArrTivRJOvE2xmmEcfq7oME5BG/4hSYSbs=";
})
