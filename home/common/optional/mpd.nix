{pkgs, ...}: {
  services.mpd = {
    # user = "gleask";
    enable = true;
    musicDirectory = /home/gleask/media/audio;
    playlistDirectory = /home/gleask/media/audio/playlists;

    extraArgs = ["--verbose"];

    extraConfig = ''
      auto_update "yes"
      restore_paused "yes"
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };

  home.packages = [
    pkgs.rmpc
  ];
}
