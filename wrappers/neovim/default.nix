_: {
  options = {
    initLua.default = ./init.lua;
    treesitterPackage.defaultFunc = { inputs }: import ./plugins/treesitter.nix inputs.nixpkgs.pkgs;
    startPlugins.defaultFunc =
      { inputs }:
      {
        __config = toString ./nvim;

        inherit (inputs.nixpkgs.pkgs.vimPlugins)
          # essentials
          canola-nvim
          blink-cmp
          conform-nvim
          lualine-lsp-progress
          lualine-nvim
          lz-n
          nvim-autopairs
          nvim-lspconfig
          nvim-surround
          #neat
          colorful-menu-nvim # Show completion types in color
          luasnip
          tiny-inline-diagnostic-nvim
          # # mini-nvim stuff
          # mini-ai
          # mini-comment
          # mini-extra # More textobjects for mini-ai
          # Colorschemes
          onedarkpro-nvim
          tokyonight-nvim
          # Dependencies
          nvim-web-devicons
          promise-async
          ;

        nvim-highlight-colors = inputs.nixpkgs.pkgs.vimPlugins.nvim-highlight-colors.overrideAttrs {
          meta.license = [ ];
        };
      };

    extraLuaPackages.default = ps: [ ps.jsregexp ];

    optPlugins.defaultFunc = { inputs }: {
      inherit (inputs.nixpkgs.pkgs.vimPlugins)
        typst-preview-nvim
        markdown-preview-nvim
        vim-fugitive
        vim-rhubarb # Make `:GBrowse` from fugitive work with Github
        ;
    };

    extraPackages.defaultFunc = { inputs }: with inputs.nixpkgs;
      [
        pkgs.lua-language-server
        pkgs.tinymist
        pkgs.nil
        pkgs.basedpyright

        # Formatters
        pkgs.stylua
        pkgs.marksman
        pkgs.nixfmt
      ];
  };
}
