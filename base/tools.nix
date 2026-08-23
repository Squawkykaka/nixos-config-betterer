{
  pkgs,
  self,
  ...
}:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    ncdu
    (self.wrappers.direnv.drv)
    (self.wrappers.jujutsu.drv)
    (self.wrappers.neovim.drv)
    (self.wrappers.git.drv)
    (self.wrappers.nushell.drv)
    trashy
    btop # resource monitor
    coreutils # basic gnu utils
    curl
    fzf # nice fuzzyfind
    fastfetch # come on, we need it
    ripgrep # better grep
    tree # cli dir tree viewer
    unzip
    nixfmt
    tldr # very nice short descriptions
    zip
    magic-wormhole
    dig
  ];
}
