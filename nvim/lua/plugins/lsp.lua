-- Configuração LSP corrigida para LazyVim
-- Arquivo: ~/.config/nvim/lua/plugins/lsp.lua

return {
  -- Configuração base do nvim-lspconfig no LazyVim
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Manter configurações existentes e adicionar as nossas
      opts.servers = opts.servers or {}

      -- TypeScript/JavaScript
      opts.servers.ts_ls = {
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
            suggest = {
              autoImports = true,
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
            suggest = {
              autoImports = true,
            },
          },
        },
      }

      -- Go
      opts.servers.gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              fieldalignment = true,
              nilness = true,
              unusedwrite = true,
              useany = true,
            },
            staticcheck = true,
            gofumpt = true,
            usePlaceholders = true,
            completeUnimported = true,
            directoryFilters = {
              "-.git",
              "-.vscode",
              "-.idea",
              "-.vscode-test",
              "-node_modules",
              "-vendor",
            },
            semanticTokens = true,
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            experimentalPostfixCompletions = true,
            hoverKind = "FullDocumentation",
            linkTarget = "pkg.go.dev",
          },
        },
      }

      return opts
    end,
  },

  -- Mason para instalar os LSPs
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "gopls",
        "goimports",
        "gofumpt",
        "golangci-lint",
        "prettier",
        "biome",
      })
    end,
  },

  -- Formatação
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      -- TypeScript/JavaScript
      opts.formatters_by_ft.javascript = { "biome", "prettier" }
      opts.formatters_by_ft.javascriptreact = { "biome", "prettier" }
      opts.formatters_by_ft.typescript = { "biome", "prettier" }
      opts.formatters_by_ft.typescriptreact = { "biome", "prettier" }
      opts.formatters_by_ft.json = { "biome", "prettier" }
      opts.formatters_by_ft.jsonc = { "biome", "prettier" }

      -- Go
      opts.formatters_by_ft.go = { "goimports", "gofumpt" }
      opts.formatters_by_ft.gomod = { "gofumpt" }
      opts.formatters_by_ft.gowork = { "gofumpt" }

      return opts
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- TypeScript/JavaScript
        "typescript",
        "tsx",
        "javascript",
        "jsdoc",
        "json",
        -- Go
        "go",
        "gomod",
        "gowork",
        "gosum",
      })
    end,
  },

  -- Plugin para forçar inicialização dos LSPs se necessário
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    config = function()
      -- Aguardar um pouco e então verificar se os LSPs estão rodando
      vim.defer_fn(function()
        local group = vim.api.nvim_create_augroup("LSPAutoStart", { clear = true })

        -- Função para verificar e iniciar LSPs
        local function ensure_lsp_running()
          local bufnr = vim.api.nvim_get_current_buf()
          local filetype = vim.bo[bufnr].filetype

          local lsp_map = {
            typescript = "ts_ls",
            typescriptreact = "ts_ls",
            javascript = "ts_ls",
            javascriptreact = "ts_ls",
            go = "gopls",
            gomod = "gopls",
            gowork = "gopls",
          }

          local lsp_name = lsp_map[filetype]
          if not lsp_name then
            return
          end

          -- Verificar se já existe cliente ativo
          local clients = vim.lsp.get_clients({ bufnr = bufnr, name = lsp_name })
          if #clients > 0 then
            return
          end

          -- Tentar iniciar o LSP
          vim.schedule(function()
            pcall(function()
              vim.cmd("LspStart " .. lsp_name)
            end)
          end)
        end

        -- Autocommands para garantir que LSPs iniciem
        vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
          group = group,
          pattern = {
            "*.ts",
            "*.tsx",
            "*.js",
            "*.jsx",
            "*.go",
            "go.mod",
            "go.work",
          },
          callback = function()
            vim.defer_fn(ensure_lsp_running, 500)
          end,
        })

        vim.api.nvim_create_autocmd("FileType", {
          group = group,
          pattern = {
            "typescript",
            "typescriptreact",
            "javascript",
            "javascriptreact",
            "go",
            "gomod",
            "gowork",
          },
          callback = function()
            vim.defer_fn(ensure_lsp_running, 500)
          end,
        })
      end, 1000)
    end,
  },

  -- Plugin adicional para Go (opcional)
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        lsp_cfg = false, -- não sobrescrever configuração LSP
        lsp_on_attach = false,
        goimports = "gopls",
        gofmt = "gofumpt",
      })
    end,
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
