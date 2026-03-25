{ pkgs, ... }:
{
  hm.services.mpd = {
    # user = "gleask";
    enable = true;
    musicDirectory = "nfs://192.168.1.44/volume1/linux-isos/music";
    playlistDirectory = "/home/gleask/media/audio/playlists";

    extraArgs = [ "--verbose" ];

    extraConfig = ''
      auto_update "yes"
      restore_paused "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };

  environment.systemPackages = [
    pkgs.rmpc
    pkgs.mpc
  ];
}
