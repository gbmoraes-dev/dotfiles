-- typescript config
return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "eslint-lsp",
        "biome",
        "prettier",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ts_ls = {},
        biome = {},
        eslint = {},
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        typescript = { "biome", "prettier" },
        typescriptreact = { "biome", "prettier" },
        javascript = { "biome", "prettier" },
        javascriptreact = { "biome", "prettier" },
        json = { "biome", "prettier" },
        css = { "biome", "prettier" },
        html = { "biome", "prettier" },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "typescript", "tsx", "javascript" })
    end,
  },
}
