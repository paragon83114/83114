return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  config = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300

    local wk = require("which-key")

    wk.add({
      { "<leader>e", group = "explorer" },
      { "<leader>e", desc = "Toggle file explorer", mode = "n" },
    })
  end,
}
