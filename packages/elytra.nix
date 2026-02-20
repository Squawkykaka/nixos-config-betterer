{
  fetchFromGitHub,
  buildGoModule,
  rustic,
  symlinkJoin,
  makeWrapper,
  ...
}:

let
  unwrapped = buildGoModule (finalAttrs: {
    pname = "elytra";
    version = "1.3.0";

    src = fetchFromGitHub {
      owner = "pyrohost";
      repo = "elytra";
      tag = "v${finalAttrs.version}";
      hash = "sha256-EtSE4Os7WwJsJGDQKAb96MhsMx1Nl72y+e/2Wo+xzHY=";
    };

    vendorHash = "sha256-f4nKkQLZcezcCpip4K6PRXUlxJGr9m7H16W4g7psGX4=";

    ldflags = [
      "-s"
      "-w"
      "-X"
      "github.com/pyrohost/elytra/system.Version=${finalAttrs.version}"
    ];
  });
in
symlinkJoin {
  name = "elytra-wrapped";

  paths = [
    unwrapped
  ];

  buildInputs = [
    makeWrapper
  ];

  postBuild = ''
    wrapProgram $out/bin/elytra \
      --set PATH ${rustic}/bin:$PATH
  '';
}
