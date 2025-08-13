-- Mason config
return {
  {
    "maosn-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP Servers
        "typescript-language-server",
        "gopls",
        "docker-language-server",
        "dockerfile-language-server",
        "docker-compose-language-service",
        "lua-language-server",
        "json-lsp",
        "yaml-language-server",

        -- Formatters
        "biome",
        "prettier",
        "goimports",
        "gofumpt",
        "yamlfmt",
        "stylua",

        -- Linters
        "eslint_d",
        "golangci-lint",
        "hadolint",
        "yamllint",

        -- Debug Adapters
        "delve", -- Go debugger

        -- Other tools
        "shellcheck",
        "shfmt",
      },
    },
  },

  -- Configuração adicional para mason-lspconfig
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "tsserver",
        "gopls",
        "dockerls",
        "docker_compose_language_service",
        "lua_ls",
        "jsonls",
        "yamlls",
      },
      automatic_installation = true,
    },
  },

  -- Configuração para mason-tool-installer (instala automaticamente as ferramentas)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "biome",
        "prettier",
        "eslint_d",
        "goimports",
        "gofumpt",
        "golangci-lint",
        "hadolint",
        "yamllint",
        "yamlfmt",
        "delve",
      },
      auto_update = false,
      run_on_start = true,
    },
  },
}
