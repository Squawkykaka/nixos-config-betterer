{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      lua-language-server
      python311Packages.python-lsp-server
      nixd
      gcc
      vimPlugins.nvim-treesitter-parsers.hyprlang
    ];
  };
}
