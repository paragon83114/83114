return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("nvim-tree").setup({
      sort = { sorter = "case_sensitive" },
      view = { width = 80 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        local function opts(desc)
          return { buffer = bufnr, desc = "nvim-tree: " .. desc }
        end
        vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
      end,
    })

    local timer
    vim.api.nvim_create_autocmd("CursorMoved", {
      pattern = "NvimTree*",
      callback = function()
        if timer then timer:stop() end
        timer = vim.defer_fn(function()
          local node = require("nvim-tree.api").tree.get_node_under_cursor()
          if node and node.type == "file" then
            require("nvim-tree.api").node.open.preview()
          end
        end, 5)
      end,
    })

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
  end,
}
