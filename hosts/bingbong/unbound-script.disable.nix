{
  pkgs ? import <nixpkgs> { },
}:
let
  lib = pkgs.lib;

  imported_file = builtins.readFile (
    builtins.fetchurl "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  );
  lines = lib.flatten (builtins.split "\n" imported_file);
  filtered = builtins.filter (
    line:
    let
      trimmed = lib.trim line;
    in
    (lib.hasPrefix "0.0.0.0" trimmed)
  ) lines;

  mapped = lib.flatten (
    map (
      line:
      let
        domain = lib.removePrefix "0.0.0.0 " line;
      in
      [
        "${domain}. A 0.0.0.0"
        "${domain}. AAAA ::1"
      ]
    ) filtered
  );

  final = builtins.toJSON { server.local-data = mapped; };
in
final
