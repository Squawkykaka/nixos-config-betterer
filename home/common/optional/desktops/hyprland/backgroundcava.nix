{pkgs, ...}: let
  startCava = pkgs.writeShellScriptBin "start" ''
    ghostty --class="com.mitchellh.ghostty.bg" --command="sleep 1 && cava" --background-opacity=0
  '';
in {
  wayland.windowManager.hyprland = {
    settings = {
      plugin.hyprwinwrap = {
        class = "com.mitchellh.ghostty.bg";

        pos_x = 0;
        pos_y = 60;
        size_x = 100;
        size_y = 40;
      };

      exec-once = ["${startCava}/bin/start"];
    };
  };
}
