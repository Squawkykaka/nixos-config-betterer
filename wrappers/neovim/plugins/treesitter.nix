pkgs:
# https://search.nixos.org/packages?channel=unstable&sort=alpha_asc&type=packages&query=vimPlugins.nvim-treesitter-parsers
pkgs.vimPlugins.nvim-treesitter.withPlugins (
  p: with p; [
    vim

    # The languages I work in everyday
    comment # highlight todos and fixmes
    gitcommit
    lua
    luadoc
    nix
    svelte

    # rarer langs
    typst
    bash
    gitignore
    git_rebase
    python
    typst

    # structured langs
    toml
    html
    css
    json
    csv
    diff
    yaml
    kdl

    # the generic ones
    cpp
    javascript
    rust
    tsx
    typescript
  ]
)
