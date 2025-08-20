-- golang config
return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        gopls = {
          keys = {
            { "<leader>cr", "<cmd>lua vim.lsp.codelens.run()<CR>", desc = "Run Code Lens" },
            { "<leader>cm", "<cmd>Go mod tidy<CR>", desc = "Go Mod Tidy" },
          },
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
                unusedwrite = true,
                useany = true,
              },
              staticcheck = true,
              gofumpt = true,
              codelenses = {
                generate = true,
                gc_details = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
            },
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    ---@class PluginLspOpts
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    ---@class PluginLspOpts
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "go", "gomod", "gosum" })
    end,
  },
}
