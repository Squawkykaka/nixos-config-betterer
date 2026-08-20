require("conform").setup({
  notify_on_error = false,
  formatters_by_ft = {
    nix = { "nixfmt" },
    lua = { "stylua" },
    python = { "ruff_fix", "ruff_organise_inputs", "ruff_format" },
  },
  formatters = {
    stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    },
  },
  format_on_save = nil,
  format_after_save = function(bufnr)
    local success = { async = true }
    local failure = nil

    if vim.b[bufnr].disable_autoformat then
      return failure
    end

    return success
  end,
})

vim.api.nvim_create_user_command("Format", function(args)
  local range = nil

  if args.count ~= -1 then
    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]

    range = {
      start = { args.line1, 0 },
      ["end"] = { args.line2, end_line:len() },
    }
  end

  require("conform").format({ range = range, async = true })
end, { range = true, bar = true })
-- cabbrv("fmt", "Format")
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
