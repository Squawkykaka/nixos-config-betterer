{ promise, ... }: {
  options.configFile.default = ./dunstrc;
  options.dropinFiles.default = promise (
    { inputs }:
    let
      inherit (inputs.nixpkgs) pkgs;
    in
    {
      "50-programs.conf" = (pkgs.formats.ini { }).generate "50-set-programs.conf" {
        global = {
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          dmenu = "${pkgs.dmenu}/bin/dmenu -p dunst";

          enable_recursive_icon_lookup = false;
          icon_path = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita/16x16/status/:${pkgs.adwaita-icon-theme}/share/icons/Adwaita/16x16/emblems/";
        };
      };
    }
  );

}
