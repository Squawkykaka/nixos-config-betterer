{ pkgs, ... }:
{
  services.mpd = {
    # user = "gleask";
    enable = true;
    musicDirectory = /home/gleask/media/audio;
    playlistDirectory = /home/gleask/media/audio/playlists;

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

  home.packages = [
    pkgs.rmpc
  ];

  # systemd.services.mpd.environment = {
  #   # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
  #   XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.gleask.uid}"; # User-id must match above user. MPD will look inside this directory for the PipeWire socket.
  # };
}
