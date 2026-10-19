{
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) concatStringsSep mapAttrsToList;
  mimeApps = {
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "application/pdf" = [ "firefox.desktop" ];
    "inode/directory" = [ "thunar.desktop" ];

    "application/zip" = [ "file-roller.desktop" ];
    "application/x-tar" = [ "file-roller.desktop" ];
    "application/x-7z-compressed" = [ "file-roller.desktop" ];
    "application/x-rar" = [ "file-roller.desktop" ];
    "application/gzip" = [ "file-roller.desktop" ];
    "application/x-bzip2" = [ "file-roller.desktop" ];
    "application/x-xz" = [ "file-roller.desktop" ];
    "application/x-compressed-tar" = [ "file-roller.desktop" ];

    "image/jpeg" = [ "feh.desktop" ];
    "image/png" = [ "feh.desktop" ];
    "image/gif" = [ "feh.desktop" ];
    "image/webp" = [ "feh.desktop" ];
    "image/apng" = [ "feh.desktop" ];
    "image/avif" = [ "feh.desktop" ];
    "image/jxl" = [ "feh.desktop" ];
    "image/svg+xml" = [ "feh.desktop" ];
  };

  mimeAppsList =
    "[Default Applications]\n"
    + concatStringsSep "\n" (
      mapAttrsToList (type: apps: "${type}=${concatStringsSep ";" apps};") mimeApps
    );
in
{
  environment.systemPackages = [
    pkgs.file-roller
    pkgs.feh
  ];

  environment.etc = {
    "xdg/mimeapps.list".text = mimeAppsList;
    "xdg/xdg-terminals.list".text = "com.mitchellh.ghostty.desktop\n";
  };
}
