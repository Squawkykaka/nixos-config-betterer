{
  fetchFromGitHub,
  php,
}:
php.buildComposerProject2 (finalAttrs: {
  pname = "pyrodactyl-backend";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "pyrohost";
    repo = "pyrodactyl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C/3FtPpGwPEGqwf96sWxu/tzfjR5r3z6yzYK38fO8hA=";
  };

  php = php.buildEnv {
    extensions = ({ enabled, all }: enabled ++ (with all; [ ast ]));
  };

  vendorHash = "sha256-Af18gqFjmdGGgzsmXkOBaJXKE2TXrSnlaOMzik7r/bI=";

  installPhase = ''
    # Create Laravel directory structure
    mkdir -p $out/bootstrap/cache
    mkdir -p $out/storage/{logs,framework/{sessions,views,cache}}

    # Remove any existing cache files
    rm -rf $out/bootstrap/cache/*.php

    # Copy necessary Laravel files
    cp -r config $out/config
    cp -r database $out/database
    cp -r routes $out/routes
    cp -r resources $out/resources
    cp -r public $out/public

    # Copy .env.example
    if [ -f .env.example ]; then
      cp .env.example $out/.env.example
    fi

    # Copy artisan CLI
    if [ -f artisan ]; then
      cp artisan $out/artisan
      chmod +x $out/artisan
    fi

    # Set proper permissions
    chmod -R 755 $out/bootstrap
    chmod -R 755 $out/storage
  '';
})
