_: {
  options = {
    initLuaFile.default = toString ./init.lua;
    treesitterPackage.defaultFunc = { inputs }: import ./plugins/treesitter.nix inputs.nixpkgs.pkgs;
    aliases.default = [
      "vim"
      "hx"
    ];
    devPlugins.default = [ (toString ./nvim) ];
    startPlugins.defaultFunc =
      { inputs }:
      {
        inherit (inputs.nixpkgs.pkgs.vimPlugins)
          vim-wakatime
          # essentials
          neorg
          canola-nvim
          blink-cmp
          conform-nvim
          lualine-lsp-progress
          lualine-nvim
          lz-n
          leap-nvim
          fzf-lua
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

    extraLuaPackages.default = ps: [
      ps.jsregexp
      ps.lua-utils-nvim
      ps.pathlib-nvim
    ];

    optPlugins.defaultFunc = { inputs }: {
      inherit (inputs.nixpkgs.pkgs.vimPlugins)
        typst-preview-nvim
        vim-fugitive
        vim-rhubarb # Make `:GBrowse` from fugitive work with Github
        ;
    };

    extraPackages.defaultFunc = { inputs }: with inputs.nixpkgs;
      [
        pkgs.lua-language-server
        pkgs.typescript-language-server
        pkgs.tinymist
        pkgs.websocat
        pkgs.nil
        pkgs.basedpyright

        # Formatters
        pkgs.stylua
        pkgs.marksman
        pkgs.nixfmt
        pkgs.svelte-language-server
        pkgs.rust-analyzer
        pkgs.wakatime-cli
      ];
  };
}
