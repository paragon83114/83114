return {
  "neovim/nvim-lspconfig",
  lazy = false,
  config = function()
    vim.lsp.config.bashls = {
      cmd = { "bash-language-server", "start" },
      filetypes = { "bash", "sh" },
      root_markers = { ".bashrc", ".bash_profile", ".profile" },
      single_file_support = true,
    }
    vim.lsp.enable("bashls")
  end,
}
