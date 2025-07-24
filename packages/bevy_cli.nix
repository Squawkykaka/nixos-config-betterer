{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  openssl,
  lld,
  pkg-config,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bevy_cli";
  version = "0.1.0-alpha.1";

  src = fetchFromGitHub {
    owner = "TheBevyFlock";
    repo = finalAttrs.pname;
    tag = "cli-v${finalAttrs.version}";
    hash = "sha256-v7BcmrG3/Ep+W5GkyKRD1kJ1nUxpxYlGGW3SNKh0U+8=";
  };

  cargoHash = "sha256-QrW0daIjuFQ6Khl+3sTKM0FPGz6lMiRXw0RKXGZIHC0=";

  buildInputs = [
    openssl
    lld
  ];

  # bevy_cli checks are all tests whether it should be built, unneeded for actual build.
  doCheck = false;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  postInstall = ''
    installShellCompletion --cmd bevy \
      --bash <($out/bin/bevy completions bash) \
      --fish <($out/bin/bevy completions fish) \
      --zsh <($out/bin/bevy completions zsh)
  '';

  meta = with lib; {
    mainProgram = "bevy";
    description = "A fast line-oriented regex search tool, similar to ag and ack";
    homepage = "https://github.com/BurntSushi/ripgrep";
    license = licenses.mit;
  };
})
