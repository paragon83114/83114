return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      view = { width = 40 },
      filters = { dotfiles = false },
    })
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
  end,
}
