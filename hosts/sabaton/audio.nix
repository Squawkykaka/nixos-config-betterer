{
  pkgs,
  lib,
  ...
}:
let
  loudmax_plugin = pkgs.stdenv.mkDerivation {
    pname = "loudmax";
    version = "1.4.7";

    src = pkgs.fetchurl {
      name = "LoudMax_v1_47_Linux_x86_LADSPA.tar.gz";
      url = "https://www.dropbox.com/scl/fi/s6aawowxty7gpj0crvjq3/LoudMax_v1_47_Linux_x86_LADSPA.tar.gz?rlkey=0lyxstuwvi8pwadlp2nouw4ns&st=0wsjtp1f&dl=1";
      hash = "sha256-9NNLo3DQrLtw8CrM49fzb9AfBUDqVEIGpjdjq92xwOU=";
    };

    dontUnpack = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = with pkgs.stdenv.cc; [
      cc
      libc
    ];

    installPhase = ''
      mkdir -p $out/lib/ladspa
      tar -xzf "$src" -C "$out/lib/ladspa"
    '';
  };
  plugins.loudmax = {
    name = "la_LoudMax64";
    pkg = loudmax_plugin;
  };

in
{
  services.pipewire = {
    extraLadspaPackages = lib.mapAttrsToList (n: v: v.pkg) plugins;
    extraConfig.pipewire.desktop-audio = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = "Desktop Audio";
            "media.name" = "Desktop Audio";
            "filter.graph".nodes = [
              {
                type = "ladspa";
                #name = "Lo";
                plugin = plugins.loudmax.name;
                label = "ldmx_stereo";
                control = {
                  "Threshold (dB)" = -28;
                  "Output (dB)" = 0;
                };
              }
            ];
            "capture.props" = {
              "node.name" = "Desktop Audio:in";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "Desktop Audio:out";
              "media.class" = "Audio/Source";
              "target.object" = "alsa_output.pci-0000_07_00.6.analog-stereo";
            };
          };
        }
      ];
    };
    wireplumber.extraConfig = {
      "51-rename-devices" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "alsa_output.pci-0000_07_00.6.analog-stereo"; } ];
            actions = {
              update-props = {
                "node.description" = "Laptop Speakers";
              };
            };
          }
        ];
      };
    };
  };
}
