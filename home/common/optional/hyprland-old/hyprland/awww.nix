{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.awww.packages.${pkgs.system}.awww
  ];

  systemd.user.services.awww-daemon = {
    Unit = {
      Description = "Awww Daemon";
      After = ["network.target"];
    };

    Service = {
      ExecStart = "${inputs.awww.packages.${pkgs.system}.awww}/bin/awww-daemon";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}
