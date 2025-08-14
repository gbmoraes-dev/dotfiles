-- Configuração melhorada para diagnósticos TypeScript
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Configurações globais de diagnóstico
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
      },
      servers = {
        ts_ls = {
          cmd = { "typescript-language-server", "--stdio" },
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(fname)
              or vim.fs.dirname(fname)
          end,
          single_file_support = true,
          init_options = {
            hostInfo = "neovim",
            preferences = {
              disableSuggestions = false,
              quotePreference = "double",
              includeCompletionsForModuleExports = true,
              includeCompletionsForImportStatements = true,
              includeCompletionsWithSnippetText = true,
            },
          },
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
              format = {
                enable = false,
              },
              -- IMPORTANTE: Configurações para diagnósticos
              preferences = {
                includePackageJsonAutoImports = "auto",
              },
              -- Habilitar todas as verificações
              check = {
                npmIsInstalled = true,
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
              format = {
                enable = false,
              },
            },
          },
          -- Configuração crucial do on_attach
          on_attach = function(client, bufnr)
            -- Habilitar inlay hints
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end

            -- IMPORTANTE: Forçar atualização de diagnósticos
            vim.schedule(function()
              vim.diagnostic.enable(bufnr)

              -- Forçar uma verificação de diagnósticos
              vim.defer_fn(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  vim.lsp.buf.document_highlight()
                  vim.cmd("doautocmd CursorHold")
                end
              end, 100)
            end)

            -- Keybindings úteis para diagnósticos
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)

            -- Keybindings LSP padrão
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          end,
          -- Configurações específicas de capabilities para diagnósticos
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.publishDiagnostics = {
              relatedInformation = true,
              versionSupport = false,
              tagSupport = {
                valueSet = {
                  1, -- Deprecated
                  2, -- Unnecessary
                },
              },
              codeDescriptionSupport = true,
              dataSupport = true,
            }
            return capabilities
          end)(),
        },
      },
    },
  },

  -- Plugin para melhorar diagnósticos
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Configurar diagnósticos globalmente
      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "✘",
            [vim.diagnostic.severity.WARN] = "▲",
            [vim.diagnostic.severity.HINT] = "⚑",
            [vim.diagnostic.severity.INFO] = "»",
          },
        },
      })

      -- Autocommands para forçar diagnósticos
      local group = vim.api.nvim_create_augroup("TypeScriptDiagnostics", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged", "TextChangedI" }, {
        group = group,
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function(args)
          local bufnr = args.buf

          -- Verificar se o LSP está ativo
          local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })
          if #clients > 0 then
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                -- Forçar refresh dos diagnósticos
                for _, client in pairs(clients) do
                  if client.server_capabilities.textDocument then
                    vim.lsp.buf_request(bufnr, "textDocument/publishDiagnostics", {
                      uri = vim.uri_from_bufnr(bufnr),
                      version = vim.lsp.util.buf_versions[bufnr],
                    })
                  end
                end
              end
            end, 200)
          end
        end,
      })

      -- Autocommand específico para mostrar diagnósticos ao mover cursor
      vim.api.nvim_create_autocmd("CursorHold", {
        group = group,
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            border = "rounded",
            source = "always",
            prefix = " ",
          })
        end,
      })
    end,
  },

  -- Plugin para melhor experiência com TypeScript
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        expose_as_code_action = "all",
        tsserver_logs = "verbose",
      },
    },
  },
}
