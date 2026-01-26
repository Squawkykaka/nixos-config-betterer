{
  stdenv,
  deno,
  fetchFromGitHub,
}:
let
in
stdenv.mkDerivation {
  pname = "invidious-companion";
  version = "master";

  src = fetchFromGitHub {
    owner = "iv-org";
    repo = "invidious-companion";
    rev = "d733c5a5a90408aaf39980de9d07c33378a8ac00";
    hash = "sha256-0Sv7AzZjLk80d2Ht5yOCglbY02iXWtFefPylJ8lccjI=";
  };

  buildInputs = [ deno ];

  buildPhase = ''
    mkdir -p $out/bin
    deno compile \
        --include ./src/lib/helpers/youtubePlayerReq.ts \
        --include ./src/lib/helpers/getFetchClient.ts \
        --allow-import=github.com:443,jsr.io:443,cdn.jsdelivr.net:443,esm.sh:443,deno.land:443 \
        --allow-net --allow-env --allow-sys=hostname \
        --allow-read=.,/var/tmp/youtubei.js,/tmp/invidious-companion.sock \
        --allow-write=/var/tmp/youtubei.js,/tmp/invidious-companion.sock \
        --target=${stdenv.targetPlatform.config} \
        --output $out/bin/invidious-companion \
        --no-remote \
        src/main.ts \
  '';
}
