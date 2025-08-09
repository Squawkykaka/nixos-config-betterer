## Things to Do

- [ ] add ssh keys and ssh hosts to a secrets file using sops-nix
- [x] setup git authentication using sops-nix
- [x] fix somewhat laggy boot time
- [x] remove some caches so that download time is reduced.
- [ ]
- [x] setup mpv for audio playing.
- [ ] make a quickshell thingy for mpd, showing on waybar
- [ ] change wireguard setup to break the interne ton stupid laptop less

```
├── config
│   ├── hosts
│   │   ├── home
│   │   │   ├── 1.nix
│   │   │   ├── 2.nix
│   │   │   └── 3.nix
│   │   └── nixos
│   │       ├── 1.nix
│   │       ├── 2.nix
│   │       └── 3.nix
│   └── home
│       └── gleask.nix
└── nix
    ├── home
    ├── modules
    ├── nixos
    ├── overlays
    └── pkgs
```
