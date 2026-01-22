{
  klibc,
  cmake,
  quiche,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "trusttunnel-client";

  version = "0.99.69";

  src = fetchFromGitHub {
    owner = "TrustTunnel";
    repo = "TrustTunnelClient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-diLYVTrzZZ2G1DTFiG8IoIA9r2mD8SKRRCbKkMVROYc=";
  };

  patches = [
    ./remove-conan.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    quiche
    klibc
  ];
})
