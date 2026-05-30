return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        enable_preview = true,
      },
      window = {
        width = 60,
      },
    })
    vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file explorer" })
  end,
}