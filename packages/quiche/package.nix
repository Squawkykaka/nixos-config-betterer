{
  libclang,
  fetchFromGitHub,
  rustPlatform,
  runCommand,
  boringssl,
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
  pname = "quiche";

  version = "0.24.5";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "quiche";
    tag = finalAttrs.version;
    hash = "sha256-Jvc5+kiMYmSg+a8UDTlUoUBpYIK+Hb1cR1WDi1tGUio=";
  };

  cargoHash = "sha256-rOImmL9CWUGKr8aJcH2AoXHR7N8gcR4FSZD+uHZWJy0=";

  env.BORING_BSSL_PATH = "${boringssl-wrapper}";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libclang
  ];

  cargoPatches = [
    # NOTE: `env_logger` didnt have correct version when directly
    # vendoring, needed to force update.
    ./add-Cargo.lock.patch
  ];

  buildFeatures = [
    "ffi"
  ];
})
