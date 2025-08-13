-- TypeScript config
return {
  -- Adicionar suporte para TypeScript/JavaScript
  { import = "lazyvim.plugins.extras.lang.typescript" },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TypeScript Language Server
        tsserver = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
    },
  },

  -- Configurar formatação com Biome
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
      },
      formatters = {
        biome = {
          command = "biome",
          args = { "format", "--stdin-file-path", "$FILENAME" },
          stdin = true,
        },
      },
    },
  },

  -- Configurar linting com Biome
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
      },
      linters = {
        biome = {
          cmd = "biome",
          args = { "lint", "--stdin-file-path", vim.api.nvim_buf_get_name(0) },
          stdin = true,
        },
      },
    },
  },
}
