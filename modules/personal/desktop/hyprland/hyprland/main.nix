{lib, ...}: let
  cfg = config.kaka.desktop.hyprland;
in {
  config = {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      settings = {
        "debug:full_cm_proto" = true;
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland"
          "XDG_SCREENSHOTS_DIR,$HOME/screens"
        ];

        monitor = [
          "eDP-1,1920x1080@60,0x0,1"
          "HDMI-A-1,2560x1440@120.00Hz,auto,1"
        ];

        "$mainMod" = "SUPER";
        "$terminal" = lib.getExe cfg.terminal;
        "$fileManager" = lib.getExe cfg.fileManager;
        "$menu" = "wofi";
        "$notes" = "obsidian";
        "$browser" = lib.getExe cfg.browser;

        exec-once = [
          "waybar"
          "wl-paste --type text --watch cliphist store"
          "wl-paste --type image --watch cliphist store"
          "[workspace 2 silent] $notes"
          "[workspace 3 silent] code"
          "[workspace 5 silent] vesktop"
          "[workspace 1] $browser"
          "nm-applet"
          "ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false"
        ];

        # … rest of your settings unchanged …
      };
    };

    home.packages = [
      cfg.browser
    ];
  };
}
