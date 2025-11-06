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
        version = "0.14.0";
        src = fetchFromGitHub {
          owner = "Myriad-Dreamin";
          repo = "tinymist";
          tag = "v${version}";

          hash = "sha256-0b9gB7vHvw1wjoTxWcQOcshpuIKfcaQJeI8GCo+rvF4=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          hash = "sha256-ctyb/llOYBiyBwKylacpXrEp3hXix64zwHxv/E54rrM=";
        };
      }))

      nodejs_24
      typst
      vimPlugins.nvim-treesitter-parsers.hyprlang
    ];
  };
}
