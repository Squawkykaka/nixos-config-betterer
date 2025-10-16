{pkgs, ...}: {
  wayland.windowManager.hyprland = {
    settings = {
      plugin.hyprwinwrap = {
        class = "hyprland-background";

        pos_x = 0;
        pos_y = 0;
        size_x = 100;
        size_y = 100;
      };

      exec-once = ["${pkgs.ghostty} --class='hyprland-background' --command='sleep 1 && ${pkgs.cava}"];
    };
  };
}
