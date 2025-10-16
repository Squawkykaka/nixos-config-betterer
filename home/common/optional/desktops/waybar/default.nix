{config, ...}: {
  programs.waybar = {
    enable = true;
    # you can use config.lib.stylix.colors.withHashtag to get the colors
    style = with config.lib.stylix.colors.withHashtag; ''
      * {
          border: none;
          border-radius: 0px;
          font-family: "JetBrains Mono";
          font-weight: bold;
          font-size: 16px;
          min-height: 0;
          color: ${base05};
        }

        window#waybar {
          background: ${base01};
        }

        /* Workspace Buttons */
        #workspaces button label{
          color: #ebdbb2;
          padding: 0 10px;
        }
        #workspaces button.active label {
          color: #1d2021;
        }
        #workspaces button.active {
          background: ${orange};
        }

        #clock, #battery, #backlight, #pulseaudio, #tray, #language, #weather {
          padding: 0 10px;
          margin: 0 10px;
        }

        #language {
          margin: 0;
          color: #d79921;
          border-bottom: 5px solid #d79921;
        }

        #pulseaudio {
          margin: 0;
          color: ${magenta};
          border-bottom: 5px solid ${magenta};
        }

        #pulseaudio.muted {
          padding: 0 20px;
          color: ${red};
          border-bottom: 5px solid ${red};
        }

        #battery {
          margin: 0;
          color: ${blue};
          border-bottom: 5px solid ${blue};
        }

        #backlight {
          margin: 0;
          color: ${green};
          border-bottom: 5px solid ${green};
        }

        #clock {
          margin: 0;
          color: ${orange};
          border-bottom: 5px solid ${orange};
        }

        #tray {
          margin: 0;
          color: ${red};
          border-bottom: 5px solid ${red};
        }

    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "battery"
          "temperature"
          "hyprland/workspaces"
          "mpd"
        ];

        modules-center = [
          "idle_inhibitor"
          "hyprland/window"
        ];

        modules-right = [
          "pulseaudio"
          "backlight"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          show-special = true;
          special-visible-only = true;
          all-outputs = false;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "magic" = "";
          };

          persistent-workspaces = {
            "*" = 5;
          };
        };

        mpd = {
          server = "127.0.0.1";
          port = 6600;

          format = "{stateIcon} {artist} - {title}";
          format-paused = "{stateIcon} <i>{artist} - {title}</i>";
          format-stopped = "...";

          on-click = "rmpc togglepause";
          on-scroll-up = "rmpc volume +5";
          on-scroll-down = "rmpc volume -5";

          state-icons = {
            paused = "";
            playing = "";
          };
        };

        temperature = {
          format = "{temperatureC}°C ";
        };

        network = {
          interface = "wlp82s0";
          format = " {icon} ";
          tooltip-format = "{essid}: {ipaddr}/{cidr}";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
        };

        backlight = {
          device = "intel_backlight";
          interval = 1;
          format = "{percent}% {icon}";
          on-scroll-up = "brightnessctl s 5%+";
          on-scroll-down = "brightnessctl s 5%-";
          format-icons = [
            ""
            ""
            ""
            "󰃝"
            "󰃞"
            "󰃟"
            "󰃠"
          ];
        };

        "pulseaudio" = {
          format = "{icon}  {volume}%";
          format-bluetooth = "{icon}  {volume}% ";
          format-muted = "";
          format-icons = {
            "headphones" = "";
            "headset" = "";
            "phone" = "";
            "car" = "󰄋";
            "default" = [
              " "
              " "
            ];
          };
          on-click = "pavucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 1;
          };
          format = "{icon}   {capacity}%";
          format-charging = "  {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "clock" = {
          format = "{:%d.%m.%Y - %H:%M}";
          format-alt = "{:%A, %B %d at %R}";
        };

        "tray" = {
          icon-size = 14;
          spacing = 1;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
      };
    };
  };
}
