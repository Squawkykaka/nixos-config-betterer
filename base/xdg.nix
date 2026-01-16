{ config, ... }:
{
  hm.xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "zen";
        "x-scheme-handler/http" = "zen";
        "x-scheme-handler/https" = "zen";
        "x-scheme-handler/about" = "zen";
        "x-scheme-handler/unknown" = "zen";
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "/home/gleask/.desktop";
      documents = "/home/gleask/documents";
      download = "/home/gleask/downloads";
      music = "/home/gleask/media/audio";
      pictures = "/home/gleask/media/images";
      videos = "/home/gleask/media/video";
      # publicshare = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below
      # templates = "/var/empty"; #using this option with null or "/var/empty" barfs so it is set properly in extraConfig below

      extraConfig = {
        # publicshare and templates defined as null here instead of as options because
        XDG_PUBLICSHARE_DIR = "/var/empty";
        XDG_TEMPLATES_DIR = "/var/empty";
      };
    };
  };
}
