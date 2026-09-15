{ lib, pkgs, ... }: {
  services.watt.enable = true;
  services.watt.package = pkgs.watt.overrideAttrs (
    final: old: {
      src = old.src.overrideAttrs {
        rev = "707ae3507b995eac6a015d877156aa4c3bc92ecd";
        hash = "sha256-hPSY5xQ5IziQrmBixtmhvzUHIHl8nIgGzxKBOlAktz8=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (final) src;
        hash = "sha256-7qkujZk9dv5CUfTN42ytP4Qj/SyWbk95uDd7NoETyDw=";
      };
      dontCheck = true;
    }
  );
  services.thermald.enable = lib.mkForce false;
  systemd.services.watt.environment.WATT_CONFIG = toString ./watt.toml;
}
