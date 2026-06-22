{ pkgs, ... }:
{
  services.mpd.enable = true;
  services.mpd.settings = {
    music_directory = "/mnt/media/music";
    playlist_directory = "/mnt/media/music/playlists";
    audio_output = [
      {
        type = "alsa";
        name = "alsa";
        device = "default";
      }
    ];
  };
  boot.supportedFilesystems = [
    "nfs"
  ];
  fileSystems."/mnt/media" = {
    device = "192.168.1.44:/volume1/linux-isos";
    fsType = "nfs";

    options = [
      "rw"
      "sec=sys"
      "noatime"
      "hard"
      "intr"
      "proto=tcp"
      "_netdev"
    ];
  };
  users.groups.media = {
    gid = 984;
  };
  systemd.services.mpd = {
    after = [ "mnt-media.mount" ];
    requires = [ "mnt-media.mount" ];
  };
  users.users.gleask.extraGroups = [ "media" ];
  users.users.mpd.extraGroups = [ "media" ];

  environment.systemPackages = [ pkgs.rmpc ];
}
