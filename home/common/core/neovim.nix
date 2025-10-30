{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      python311Packages.python-lsp-server
      nixd
      lua-language-server
      rust-analyzer
      lua5_1
      luarocks
      cargo
      fd
      stylua
      typstyle
      tree-sitter
      go
      python3
      gcc
      (tinymist.overrideAttrs (prev: rec {
        version = "0.14.0-rc1";
        src = fetchFromGitHub {
          owner = "Myriad-Dreamin";
          repo = "tinymist";
          tag = "v${version}";

          hash = "sha256-a4AMk38TAaQQos+XRsQ7pm8cSDMfiszCO9DEQ5XQgI8=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-9D7zThRN5ipzgpnmAx7UZ1E8V6r0DRaQEY4RfmAT74E=";
        };
      }))

      nodejs_24
      typst
      vimPlugins.nvim-treesitter-parsers.hyprlang
    ];
  };
}
