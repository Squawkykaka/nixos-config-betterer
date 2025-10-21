{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    # FIX Will return back to normal after nixpkgs updates
    (r2modman.overrideAttrs (oldAttrs: rec {
      version = "3.2.9";

      src = fetchFromGitHub {
        owner = "ebkr";
        repo = "r2modmanPlus";
        rev = "v3.2.9";
        hash = "sha256-rnW8itUsP2a09gQU3IXZI7kSVKIxxCgbt15NoH/g0a8=";
      };

      preBuild = ''
        # Sass doesnt play nice with nix
        rm -r node_modules/sass-embedded*
      '';

      offlineCache = fetchYarnDeps {
        yarnLock = "${src}/yarn.lock";
        hash = "sha256-V6N0RIjT3etoP6XdZhnQv4XViLRypp/JWxnb0sBc6Oo=";
      };
    }))
    (lutris.override {
      extraPkgs = _pkgs: [
        wineWowPackages.stable
        geckodriver
      ];
    })
  ];

  programs = {
    steam = {
      enable = true;
      protontricks = {
        enable = true;
        package = pkgs.protontricks;
      };
      package = pkgs.steam.override {
        extraPkgs = pkgs: (builtins.attrValues {
          inherit
            (pkgs.xorg)
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
            ;

          inherit
            (pkgs.stdenv.cc.cc)
            lib
            ;

          inherit
            (pkgs)
            libpng
            libpulseaudio
            libvorbis
            libkrb5
            keyutils
            gperftools
            ;
        });
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };

    gamemode = {
      enable = true;
      settings = {
        #see gamemode man page for settings info
        general = {
          softrealtime = "on";
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0; # The DRM device number on the system (usually 0), ie. the number in /sys/class/drm/card0/
          amd_performance_level = "high";
          nvidia_performance_level = "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };
}
