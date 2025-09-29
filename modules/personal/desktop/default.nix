{
  # config,
  lib,
  ...
}: {
  options = {
    kaka.desktop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether to enable my custom desktop, this includes hyprland and the tools associated with it.
        '';
      };
    };
  };
}
