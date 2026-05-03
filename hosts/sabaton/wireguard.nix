{
  config,
  ...
}:
{
  networking.wg-quick.interfaces.wg0 = {
    address = [ "192.168.2.3/32" ];
    privateKeyFile = config.sops.secrets."sabaton/private_key".path;
    dns = [ "10.0.0.76" ];
    peers = [
      {
        publicKey = "mKnXJRvRByS+CqIHJIg056fjDjVfxzqFYRFi4rQIShc=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "203.211.123.150:41654";
      }
    ];
  };

  sops.secrets."sabaton/private_key" = { };
}
