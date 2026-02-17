{
  dockerTools,
  buildEnv,
  pyrodactyl,
  php,
}:

dockerTools.buildImage {
  name = "pyrodactyl";
  tag = "v4.5.0";

  copyToRoot = buildEnv {
    name = "image-root";
    paths = [
      pyrodactyl
      php
    ];
    pathsToLink = [
      "/bin"
      "/app"
    ];
  };

  config = {
    # Example:
    # Cmd = [ "pyrodactyl" ];
  };
}
