{ pkgs, ... }:
{
  services.kanidm.client.enable = true;
  services.kanidm.package = pkgs.kanidm_1_9;
  services.kanidm.client.settings = {
    uri = "https://idm.smeagol.me";
    ca_path = "/home/gleask/.config/kanidm/ca.pem";
  };
}
