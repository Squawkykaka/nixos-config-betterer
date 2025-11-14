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
      tree-sitter
      go
      python3
      gcc
      tinymist
      nodejs_24
      typst
      vimPlugins.nvim-treesitter-parsers.hyprlang
    ];
  };
}
