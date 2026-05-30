return {
  "NeogitOrg/neogit",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("neogit").setup({
      use_popup_navigation = true,
      disable_builtin_padding = true,
      graph_style = "unicode",
      auto_refresh = true,
      signs = {
        section = { ">", "v" },
        item = { "+", "-" },
        folded = { ">", "v" },
      },
    })
    vim.keymap.set("n", "<leader>git", "<cmd>Neogit<cr>", { desc = "Open Neogit" })
  end,
}