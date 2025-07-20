## Things to Do

- [ ] add ssh keys and ssh hosts to a secrets file using sops-nix
- [ ] setup git authentication using sops-nix
- [x] fix somewhat laggy boot time
- [ ] remove some caches so that download time is reduced.
- [ ]
- [ ] setup mpv for audio playing.
- [ ] make a quickshell thingy for mpd, showing on waybar

Rework into

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
│   └── users
│       └── gleask.nix
└── nix
    ├── home
    ├── modules
    ├── nixos
    ├── overlays
    └── pkgs
```
