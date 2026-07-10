{ pkgs, ... }:
{
  services.mpd.enable = true;
  services.mpd.settings = {
    music_directory = "nfs://192.168.1.44/volume1/linux-isos/music";
    playlist_directory = "/home/gleask/media/audio/playlists";
    audio_output = [
      {
        type = "alsa";
        name = "alsa";
        device = "default";
      }
    ];
  };

  environment.systemPackages = [ pkgs.rmpc ];
}
