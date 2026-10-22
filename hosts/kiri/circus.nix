{
  self,
  ...
}:
let
  flakeCompat = import ../../lib/flakeCompat.nix;
  circus = flakeCompat { src = self.sources.circus; };
in
{
  imports = [ circus.outputs.nixosModules.default ];
  services.circus = {
    enable = true;
    server.enable = true;
    evaluator.enable = true;
    queueRunner.enable = true;

    settings = {
      server.host = "127.0.0.1";
      server.port = 9342;

      server.force_secure_cookies = true;
      server.rate_limit_rps = 100;
      server.rate_limit_burst = 20;

      evaluator.poll_interval = 300;
      evaluator.restrict_eval = true;
      queue_runner.workers = 4;
      queue_runner.build_timeout = 7200;

      gc.enabled = true;
      gc.max_age_days = 90;

      cache.enabled = true;
      logs.log_dir = "/var/lib/circus/logs";
      logs.compress = true;
    };
  };

  services.caddy.virtualHosts."build.squawkykaka.com".extraConfig = ''
    reverse_proxy 127.0.0.1:9342 

    request_body {
      max_size 50MB
    }
  '';
}
