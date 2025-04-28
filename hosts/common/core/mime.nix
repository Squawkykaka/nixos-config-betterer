# TODO move to home config, https://github.com/EmergentMind/nix-config/blob/dev/home/ta/common/optional/xdg.nix

{
  # Fix this to grab whatever the browser actually is
  xdg.mime.defaultApplications = {
    "inode/directory" = "thunar";
  };
}
