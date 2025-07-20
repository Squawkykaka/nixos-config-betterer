{
  lib,
  config,
  ...
}: {
  programs.waybar = {
    enable = true;
    # you can use config.lib.stylix.colors.withHashtag to get the colors
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          (lib.mkIf (config.services.mpd.enable == true) "mpd")
        ];

        modules-center = ["hyprland/window"];
        modules-right = [
          "pulseaudio"
          "battery"
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
            "magic" = "";
          };

          persistent-workspaces = {
            "*" = 5;
          };
        };

        mpd = {
          server = "127.0.0.1";
          port = 6600;

          format = "{artist} - {title}";
          format-stopped = "{stateIcon} Stopped";
          format-paused = "Paused";

          on-click = "rmpc togglepause";
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
      };
    };
  };
}
