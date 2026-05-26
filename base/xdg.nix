{pkgs,...}:{
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-wlr];
  environment.etc."xdg/user-dirs.defaults".text = ''
    DESKTOP=.desktop
    DOWNLOAD=downloads
    TEMPLATES=/var/empty
    PUBLICSHARE=/var/empty
    DOCUMENTS=documents
    MUSIC=media/audio
    PICTURES=media/images
    VIDEOS=media/video
  '';
}
