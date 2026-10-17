{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "numa";
  version = "0.24.1";

  src = fetchFromGitHub {
    owner = "razvandimescu";
    repo = "numa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fKdWDB+6P5kkyrCgKXWMsJA/MO460WYtVEifv9L5ekk=";
  };

  cargoHash = "sha256-7dizqZL8wYsQ9B3DaopJWxNLst8iM+L71U+t9sXLf8w=";

  meta = {
    description = "Portable DNS resolver in Rust — .numa local domains, ad blocking, developer overrides";
    homepage = "https://numa.rs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
