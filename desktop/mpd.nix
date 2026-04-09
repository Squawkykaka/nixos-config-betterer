{ pkgs, ... }:
{
  fileSystems."/mnt/media" = {
    device = "192.168.1.44:/volume1/linux-isos";
    fsType = "nfs";

    options = [
      "rw"
      "sec=sys"
      "noatime"
      "soft"
      "_netdev"
    ];

    neededForBoot = false;
  };

  hm.services.mpd = {
    enable = false;
    musicDirectory = "/mnt/media/music";
    playlistDirectory = "/mnt/media/music/playlists";

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
