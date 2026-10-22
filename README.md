Welcome to my nixos config :) your welcome to look around and "borrow" any code, but keep in mind its designed for my
setup, (as anyone should) so some things will need to be modified. 

I make use of adios and adios-wrappers, which will be unfamilier to basically everyone, i highly reccomend checking them
out, mine are under the `wrappers/` directory. I also dont use homemangager or hm, though that will probably change if i
ever want to theme. 
osts:
- bandier - Oracle VPS
- kiri - old desktop pc
- bingbong - proxmox vm
- sabaton - laptop
- simba - tower
- zhara - raspberry pi

Possible idea for a new layout?
```nix
.
├── default.nix
└── root
    ├── desktop
    │   ├── applications.nix
    │   ├── gnome
    │   │   ├── @bingbong
    │   │   │   └── hardware-configuration.nix
    │   │   ├── gnome.nix
    │   │   ├── gnome-theming.nix
    │   │   └── @sabaton
    │   └── plasma
    │       ├── plasma-config.nix
    │       ├── @simba
    │       └── wallpaper.nix
    ├── hardening.nix
    ├── kernel.nix
    └── server
        ├── docker.nix
        ├── @kiri
        │   └── hardware-configuration.nix
        └── rss.nix
```
