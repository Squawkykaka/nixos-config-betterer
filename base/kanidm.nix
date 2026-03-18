{ pkgs, ... }:
{
  services.kanidm.client.enable = true;
  services.kanidm.package = pkgs.kanidm_1_9;
  services.kanidm.client.settings = {
    uri = "https://idm.smeagol.me";
    ca_path = "/etc/kanidm/ca.pem";
  };

  services.kanidm.unix = {
    sshIntegration = false;
    enable = false;
    settings.kanidm.pam_allowed_login_groups = [ "pam-computers" ];
  };
}
