{
  self,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ((import self.sources.hjem {
      inherit pkgs;
      finix = null;
    }).nixosModules.default
    )
  ];
  hjem.users.gleask.files = {
    ".icons/breeze-dark".source = pkgs.kdePackages.breeze-icons + /share/icons/breeze;
    ".icons/macOS".source = pkgs.apple-cursor + /share/icons/macOS;
    ".config/gtk-3.0/settings.ini".text = lib.generators.toINI { } {
      Settings = {
        gtk-theme-name = "Breeze";
        gtk-icon-theme-name = "Breeze";
        gtk-font-name = "Noto Sans 11";
        gtk-cursor-theme-name = "macOS";
        gtk-cursor-theme-size = 24;

        gtk-button-images = 0;
        gtk-menu-images = 0;
        gtk-enable-event-sounds = 0;
        gtk-enable-input-feedback-sounds = 0;
        # light modeee
        gtk-application-prefer-dark-theme = 0;
      };
    };
    ".config/gtk-4.0/settings.ini".text = lib.generators.toINI { } {
      Settings = {
        gtk-theme-name = "Breeze";
        gtk-icon-theme-name = "Breeze";
        gtk-font-name = "Noto Sans 11";
        gtk-cursor-theme-name = "macOS";
        gtk-cursor-theme-size = 24;
        # light modee
        gtk-application-prefer-dark-theme = 0;
      };
    };
    ".gtkrc-2.0".text = ''
      gtk-theme-name="Breeze"
      gtk-icon-theme-name="Breeze"
      gtk-font-name="Noto Sans  11"
      gtk-cursor-theme-name="macOS"
      gtk-cursor-theme-size=24
      gtk-button-images=0
      gtk-menu-images=0
      gtk-enable-event-sounds=0
      gtk-enable-input-feedback-sounds=0
    '';
  };
}
