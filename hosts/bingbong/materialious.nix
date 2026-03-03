{
  virtualisation.oci-containers.containers.materialious = {
    autoStart = true;
    image = "wardpearce/materialious-full:latest";
    volumes = [ "materialious-data:/materialious-data" ];
    environment = {
      COOKIE_SECRET = "sdafwe8awo3rhffasadsfd";
      DATABASE_CONNECTION_URI = "sqlite:///materialious-data/materialious.db";
      PUBLIC_INTERNAL_AUTH = "false";
      PUBLIC_REGISTRATION_ALLOWED = "false";
      PUBLIC_CAPTCHA_DISABLED = "false";
      PUBLIC_DEFAULT_INVIDIOUS_INSTANCE = "https://invidious.boom.boats";

      PUBLIC_DEFAULT_RETURNYTDISLIKES_INSTANCE = "https://returnyoutubedislikeapi.com";
      PUBLIC_DEFAULT_SPONSERBLOCK_INSTANCE = "https://sponsor.ajay.app";
      PUBLIC_DEFAULT_DEARROW_INSTANCE = "https://sponsor.ajay.app";
      PUBLIC_DEFAULT_DEARROW_THUMBNAIL_INSTANCE = "https://dearrow-thumb.ajay.app";
    };
    ports = [ "127.0.0.1:6754:3000" ];

  };
}
