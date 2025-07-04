{ lib, ... }:
{
  services.borgbackup.jobs."borgbase" = {
    paths = [
      "/var/lib"
      "/srv"
      "/home"
    ];

    exclude = lib.flatten [
      "**/.direnv"
      "**/.cache"
      "**/.npm"
      "**/.npm-global"
      "**/.node-gyp"
      "**/.yarn"
      "**/.pnpm-store"
      "**/.m2"
      "**/.gradle"
      "**/.opam"
      "**/.clangd"
      # Python
      "**/*.pyc"
      # Rust
      "**/.cargo"
      "**/.rustup"
      "**/target" # FIXME(borg): This might be too aggressive
      # Nix
      "**/result"
      # Lua
      "**/.luarocks"
      # /home/*/<foo> entries
      (lib.map (path: "/home/${path}") [
        # Common home cache files/directories
        "*/.mozilla/firefox/*/storage"
        "*/Android"
        "*/mount"
        "*/mnt"
        "*/.cursorless"
        # Go
        "*/go/pkg"
      ])

      # Root folders, these only matter on non-impermanence systems
      "/dev"
      "/proc"
      "/sys"
      "/var/run"
      "/run"
      "/lost+found"
      "/mnt"

      # FIXME(borg): To double check
      "/var/lib/lxcfs"

      # System cache files/directories
      "/var/lib/containerd"
      "/var/lib/docker/"
      "/var/lib/systemd"
      "/var/cache"
      "/var/tmp"
    ];

    repo = "e0e9bjd2@e0e9bjd2.repo.borgbase.com:repo";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat /etc/borg/passphrase";
    };
    environment.BORG_RSH = "ssh -i /home/gleask/.ssh/id_borgbase";
    compression = "auto,lzma";
    startAt = "daily";
  };
}
