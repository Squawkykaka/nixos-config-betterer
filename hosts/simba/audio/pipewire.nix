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

  plugins = {
    loudmax = {
      name = "la_LoudMax64";
      pkg = loudmax_plugin;
    };
    dfn = {
      name = "libdeep_filter_ladspa";
      pkg = pkgs.deepfilternet;
    };
  };
  pluginPackages = lib.mapAttrsToList (n: v: v.pkg) plugins;

  # taken from partlyAwesome/nixos
  createAudioSink = name: {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = name;
          "node.description" = name;
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
          "monitor.channel-volumes" = "true";
          "monitor.passthrough" = "true";
          "adapter.auto-port-config" = {
            "mode" = "dsp";
            "monitor" = "true";
            "position" = "preserve";
          };
        };
      }
    ];
  };

  createFilterChain =
    {
      name,
      plugin,
      label,
      control ? null,
      captureProps ? { },
      playbackProps ? { },
    }:
    {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";
          args = {
            "node.description" = name;
            "media.name" = name;
            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  inherit name plugin label;
                  control = lib.mkIf (control != null) control;
                }
              ];
            };
            "capture.props" = {
              "node.name" = "${name} Input";
              "node.passive" = true;
            }
            // captureProps;
            "playback.props" = {
              "node.name" = "${name} Output";
              "media.class" = "Audio/Source";
            }
            // playbackProps;
          };
        }
      ];
    };

  createLoudMaxNode =
    name: threshold:
    createFilterChain {
      inherit name;
      plugin = plugins.loudmax.name;
      label = "ldmx_stereo";
      control = {
        "Threshold (dB)" = -threshold;
        "Output (dB)" = 0;
      };
      captureProps = {
        "node.autoconnect" = "false";
        "audio.position" = "FL,FR";
      };
      playbackProps = {
        "audio.position" = "FL,FR";
      };
    };

  createDeepFilterNode =
    name: channels: position:
    createFilterChain {
      inherit name;
      plugin = plugins.dfn.name;
      label = "deep_filter_${channels}";
      control = {
        "Attenuation Limit (dB)" = 100;
      };
      captureProps = {
        "node.autoconnect" = "false";
        "audio.position" = position;
      };
      playbackProps = {
        "audio.position" = position;
      };
    };
  createMonoDFNNode = name: createDeepFilterNode name "mono" "MONO";
  createStereoDFNNode = name: createDeepFilterNode name "stereo" "FL,FR";

  createRNNoiseNode =
    name:
    createFilterChain {
      inherit name;
      plugin = plugins.rnnoise.name;
      label = "noise_suppressor_mono";
      control = {
        "VAD Threshold (%)" = 50.0;
        "VAD Grace Peroid (ms)" = 200;
        "Retroactive VAD Grace (ms)" = 0;
      };
      captureProps = {
        "node.autoconnect" = "false";
        "audio.position" = "MONO";
      };
      playbackProps = {
        "audio.position" = "MONO";
      };
    };

  createParaEQ = desc: path: input: output: {
    "context.modules" = [
      {
        name = "libpipewire-module-parametric-equalizer";
        args = {
          "equalizer.filepath" = path;
          "equalizer.description" = desc;
          "audio.channels" = "2";
          "audio.position" = "FL,FR";
          "capture.props" = {
            "node.name" = input;
            "node.autoconnect" = "false";
            "node.passive" = "true";
            "monitor.passthrough" = "false";
          };
          "playback.props" = {
            "node.name" = output;
            "node.autoconnect" = "false";
            "node.passive" = "true";
          };
        };
      }
    ];
  };
in
{
  services.pipewire = {
    extraLadspaPackages = pluginPackages;
    extraConfig.pipewire = {
      desktop-audio = createAudioSink "Desktop Audio";
      discord-audio = createAudioSink "Discord Audio";
      game-audio = createAudioSink "Game Audio";

      desktop-compressor = createLoudMaxNode "Desktop Compressor" 25.0;
      discord-compressor = createLoudMaxNode "Discord Compressor" 28.0;
      game-compressor = createLoudMaxNode "Game Compressor" 15.0;

      dfn = createMonoDFNNode "Mic DeepFilterNet";
      dfn-discord = createStereoDFNNode "Discord DeepFilterNet";
    };
    wireplumber = {
      extraConfig = {
        "99-auto-connect" = {
          "wireplumber.components" = [
            {
              name = "startup/auto-connect-ports.lua";
              type = "script/lua";
              provides = "custom.auto-connect-ports";
            }
          ];
          "wireplumber.profiles" = {
            main = {
              "custom.auto-connect-ports" = "required";
            };
          };
        };

      };
      extraScripts = {
        "startup/auto-connect-ports.lua" = builtins.readFile ./auto-connect-ports.lua;
      };
    };
  };
}
