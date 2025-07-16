{ pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/gleask/media/audio";

    services.mpd.extraConfig = ''
      audio_output {
        type "pipewire"
        name "My PipeWire Output"
      }
    '';
    network.listenAddress = "any"; # if you want to allow non-localhost connections
    network.startWhenNeeded = true; # systemd feature: only start MPD service upon connection to its socket
  };

  environment.systemPackages = [
    pkgs.rmpc
  ];
}
