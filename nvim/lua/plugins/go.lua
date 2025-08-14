-- Configuração Go LSP melhorada e robusta
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("go.work", "go.mod", ".git")(fname)
              or util.find_git_ancestor(fname)
              or vim.fs.dirname(fname)
          end,
          single_file_support = true,
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
          },
          settings = {
            gopls = {
              -- Análises avançadas
              analyses = {
                unusedparams = true,
                shadow = true,
                fieldalignment = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
              },
              -- Verificações estáticas
              staticcheck = true,
              gofumpt = true,

              -- Completação
              usePlaceholders = true,
              completeUnimported = true,

              -- Filtros de diretório
              directoryFilters = {
                "-.git",
                "-.vscode",
                "-.idea",
                "-.vscode-test",
                "-node_modules",
                "-vendor",
              },

              -- Tokens semânticos
              semanticTokens = true,

              -- Inlay hints (dicas visuais)
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },

              -- Configurações experimentais
              experimentalPostfixCompletions = true,
              experimentalUseInvalidMetadata = true,

              -- Hover e documentação
              hoverKind = "FullDocumentation",
              linkTarget = "pkg.go.dev",

              -- Build tags
              buildFlags = { "-tags", "integration" },
            },
          },
          -- Configuração de capabilities específica para Go
          capabilities = (function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            capabilities.textDocument.completion.completionItem.resolveSupport = {
              properties = { "documentation", "detail", "additionalTextEdits" },
            }
            return capabilities
          end)(),
          -- On attach customizado
          on_attach = function(client, bufnr)
            -- Habilitar inlay hints
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end

            -- Organize imports automaticamente ao salvar
            if client.name == "gopls" then
              vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                  local params = vim.lsp.util.make_range_params()
                  params.context = { only = { "source.organizeImports" } }
                  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
                  for cid, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                      if r.edit then
                        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                        vim.lsp.util.apply_workspace_edit(r.edit, enc)
                      end
                    end
                  end
                end,
              })
            end

            -- Keybindings específicos para Go
            local opts = { buffer = bufnr, silent = true }

            -- LSP padrão
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

            -- Específicos para Go
            vim.keymap.set("n", "<leader>go", function()
              vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" } },
                apply = true,
              })
            end, { buffer = bufnr, desc = "Organize Imports" })

            -- Diagnósticos
            vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          end,
        },
      },
    },
  },

  -- Plugin separado para garantir inicialização do Go LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Aguardar antes de configurar autocommands
      vim.defer_fn(function()
        local group = vim.api.nvim_create_augroup("GoLSPForce", { clear = true })

        -- Função para garantir que o gopls inicie
        local function ensure_gopls_started(bufnr)
          local filetype = vim.bo[bufnr].filetype
          local go_filetypes = { "go", "gomod", "gowork", "gotmpl" }

          if not vim.tbl_contains(go_filetypes, filetype) then
            return
          end

          -- Verificar se já tem cliente ativo
          local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })
          if #clients > 0 then
            return
          end

          -- Tentar iniciar o gopls
          vim.schedule(function()
            local success, err = pcall(function()
              vim.cmd("LspStart gopls")
            end)

            if not success then
              vim.notify("Erro ao iniciar gopls: " .. tostring(err), vim.log.levels.WARN)
            else
              vim.notify("gopls iniciado para buffer " .. bufnr, vim.log.levels.INFO)
            end
          end)
        end

        -- Autocommand para FileType
        vim.api.nvim_create_autocmd("FileType", {
          group = group,
          pattern = { "go", "gomod", "gowork", "gotmpl" },
          callback = function(args)
            vim.defer_fn(function()
              ensure_gopls_started(args.buf)
            end, 100)
          end,
        })

        -- Autocommand para BufEnter
        vim.api.nvim_create_autocmd("BufEnter", {
          group = group,
          pattern = { "*.go", "go.mod", "go.work", "*.gotmpl" },
          callback = function(args)
            local filename = vim.api.nvim_buf_get_name(args.buf)
            if filename == "" or not vim.loop.fs_stat(filename) then
              return
            end

            vim.defer_fn(function()
              ensure_gopls_started(args.buf)
            end, 200)
          end,
        })

        -- Debug: notificar quando gopls se conectar
        vim.api.nvim_create_autocmd("LspAttach", {
          group = group,
          callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client and client.name == "gopls" then
              vim.notify("gopls anexado ao buffer " .. args.buf, vim.log.levels.INFO)
            end
          end,
        })
      end, 500)
    end,
  },

  -- Mason para instalar gopls
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "gopls",
        "goimports",
        "gofumpt",
        "golangci-lint",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "gopls" },
      automatic_installation = true,
    },
  },

  -- Formatação para Go
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofumpt" },
        gomod = { "gofumpt" },
        gowork = { "gofumpt" },
      },
      -- Formato ao salvar
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -- Linting para Go
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft

      -- Configurar golangci-lint
      lint.linters.golangcilint.args = {
        "run",
        "--out-format=json",
        "--show-stats=false",
        "--print-issued-lines=false",
        "--print-linter-name=false",
      }

      -- Auto-lint ao salvar
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("GoLinting", { clear = true }),
        pattern = { "*.go" },
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- Treesitter para Go
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "go",
        "gomod",
        "gowork",
        "gosum",
      },
    },
  },

  -- Plugin adicional para melhor experiência com Go
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        goimports = "gopls", -- usar gopls para imports
        gofmt = "gofumpt", -- usar gofumpt para formatação
        max_line_len = 120,
        tag_transform = false,
        test_dir = "",
        comment_placeholder = "   ",
        icons = { breakpoint = "🧘", currentpos = "🏃" },
        verbose = false,
        log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
        lsp_cfg = false, -- não configurar LSP automaticamente
        lsp_gofumpt = true,
        lsp_on_attach = false, -- usar nossa configuração
        dap_debug = true,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
  },
}
