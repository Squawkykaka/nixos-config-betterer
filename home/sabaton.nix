{...}: {
  imports = [
    #
    # ========== Required Configs ==========
    #
    common/core

    #
    # ========== Host-specific Optional Configs ==========
    #
    common/optional/browsers
    common/optional/desktops
    common/optional/comms
    common/optional/development

    common/optional/obsidian.nix
    common/optional/atuin.nix
    common/optional/ghostty.nix
    common/optional/mpd.nix
  ];
}
