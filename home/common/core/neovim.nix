{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      python311Packages.python-lsp-server
      nixd
      lua-language-server
      gcc
      nodejs_24
      vimPlugins.nvim-treesitter-parsers.hyprlang
    ];
  };
}
