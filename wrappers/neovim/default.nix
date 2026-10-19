{ promise, ... }: {
  options = {
    package.default = promise (
      { inputs }:
      let
        inherit (inputs.nixpkgs.pkgs) neovim-unwrapped fetchFromGitHub;
      in
      neovim-unwrapped.overrideAttrs (oldAttrs: {
        doCheck = false;
        doInstallCheck = false;
        src = fetchFromGitHub {
          owner = "neovim";
          repo = "neovim";
          rev = "fb1f321b0efb31101891ec6cc93d4087bc4ee325";
          hash = "sha256-iu27Z3oFBjEgjFRFpGsaNMslywFY7TbdDkBixWMxLOw=";
        };
        # patches = (oldAttrs.patches or [ ]) ++ [ ./patches/better-e-binding.patch ];
      })
    );
    initLuaFile.default = toString ./init.lua;
    treesitterPackage.default = promise (
      { inputs }: import ./plugins/treesitter.nix inputs.nixpkgs.pkgs
    );
    aliases.default = [
      "vim"
      "hx"
    ];
    devPlugins.default = [ (toString ./nvim) ];
    startPlugins.default = promise (
      { inputs }:
      {
        inherit (inputs.nixpkgs.pkgs.vimPlugins)
          auto-session
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
          # mini-extra # More textobjects for mini-ai
          # mini-comment
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
      }
    );

    extraLuaPackages.default = ps: [
      ps.jsregexp
      ps.lua-utils-nvim
      ps.pathlib-nvim
    ];

    optPlugins.default = promise (
      { inputs }: {
        inherit (inputs.nixpkgs.pkgs.vimPlugins)
          typst-preview-nvim
          vim-fugitive
          vim-rhubarb # Make `:GBrowse` from fugitive work with Github
          ;
      }
    );

    extraPackages.default = promise (
      { inputs }: with inputs.nixpkgs;
      [
        pkgs.lua-language-server
        # pkgs.typescript-language-server
        pkgs.tinymist
        pkgs.websocat
        pkgs.nil
        pkgs.basedpyright

        # Formatters
        pkgs.stylua
        pkgs.marksman
        pkgs.nixfmt
        pkgs.svelte-language-server
        pkgs.wakatime-cli
      ]
    );
  };
}
