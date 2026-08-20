local blink = require("blink.cmp")

vim.lsp.config("*", {
  capabilities = blink.get_lsp_capabilities(),
})

vim.keymap.set("c", "<Tab>", "<Nop>")
vim.keymap.set("c", "<S-Tab>", "<Nop>")

vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-n>", "<Down>")
vim.keymap.set("c", "<Up>", "<Nop>")
vim.keymap.set("c", "<Down>", "<Nop>")

blink.setup({
  keymap = {
    preset = "none",

    ["<C-space>"] = { "show", "hide" },

    ["<C-j>"] = { "select_next", "fallback" },
    ["<C-k>"] = { "select_prev", "fallback" },

    ["<C-l>"] = { "accept", "fallback" },
    ["<CR>"] = { "accept", "fallback" },

    ["<Tab>"] = { "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "fallback" },
  },

  completion = {
    list = {
      selection = {
        preselect = true,
        -- Ghost text is preferable
        auto_insert = false,
      },
    },
    ghost_text = { enabled = true },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 0,
    },

    accept = { auto_brackets = { enabled = true } },

    menu = {
      draw = {
        columns = { { "kind_icon" }, { "label", "label_description" } },
        components = {
          label = {
            -- Removes label_details from being added to label by default
            -- See https://github.com/Saghen/blink.cmp/issues/843
            text = function(ctx)
              return ctx.label
            end,
            -- colorize each completion type
            highlight = require("colorful-menu").blink_components_highlight,
          },
        },
      },
    },
  },

  snippets = {
    preset = "luasnip",
    active = function()
      local ls = require("luasnip")
      local mode = vim.api.nvim_get_mode().mode
      if ls.in_snippet() and not blink.is_visible() then
        return true
      elseif not ls.in_snippet() and mode == "n" then
        ls.unlink_current()
      end
      return false
    end,
  },

  signature = {
    enabled = true,
    window = { show_documentation = true },
  },

  sources = {
    default = { "lsp", "path", "snippets", "omni" },
    per_filetype = {
      nix = { "path", "snippets", "omni" },
      lua = { "lsp", "path", "snippets", "omni" },
    },

    providers = {
      snippets = { opts = { show_autosnippets = false } },
      --     lazydev = {
      -- name = "LazyDev",
      -- module = "lazydev.integrations.blink",
      -- score_offset = 100,
      --   },
    },
  },
})
