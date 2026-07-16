{
  services.watt.enable = true;
  systemd.services.watt.environment.WATT_CONFIG = toString ./watt.toml;
}
