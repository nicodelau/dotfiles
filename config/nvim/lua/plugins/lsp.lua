return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          mason = "html-lsp",
        },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html-lsp",
        "prettier",
      })
    end,
  },
}
