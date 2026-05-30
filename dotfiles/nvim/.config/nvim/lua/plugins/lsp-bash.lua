return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "bash", "sh" },
        root_pattern = { ".bashrc", ".bash_profile", ".profile" },
        single_file_support = true,
      },
    },
  },
}
