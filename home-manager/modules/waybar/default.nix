{
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "custom/weather"
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
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "magic" = "";
          };

          persistent-workspaces = {
            "*" = 5;
          };
        };

        "custom/weather" = {
          format = " {} ";
          exec = "curl -s 'wttr.in/Tashkent?format=%c%t'";
          interval = 300;
          class = "weather";
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
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% ";
          format-muted = "";
          format-icons = {
            "headphones" = "";
            "headset" = "";
            "phone" = "";
            "car" = "";
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
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
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
