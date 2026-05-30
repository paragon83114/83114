return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
}
