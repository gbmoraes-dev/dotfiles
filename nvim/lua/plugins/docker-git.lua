-- Docker and Git config
return {
  -- Adicionar suporte para Docker
  { import = "lazyvim.plugins.extras.lang.docker" },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Docker Language Server
        dockerls = {
          settings = {
            docker = {
              languageserver = {
                formatter = {
                  ignoreMultilineInstructions = true,
                },
              },
            },
          },
        },
        -- Docker Compose Language Server
        docker_compose_language_service = {
          filetypes = { "yaml.docker-compose", "yml" },
        },
      },
    },
  },

  -- Configurar formatação para arquivos Docker e YAML
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        dockerfile = { "hadolint" },
        yaml = { "prettier", "yamlfmt" },
        yml = { "prettier", "yamlfmt" },
      },
    },
  },

  -- Linting para Docker
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        dockerfile = { "hadolint" },
        yaml = { "yamllint" },
        yml = { "yamllint" },
      },
    },
  },

  -- Adicionar treesitter para arquivos relacionados
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "dockerfile",
        "yaml",
        "gitignore",
        "gitcommit",
        "git_rebase",
        "git_config",
      },
    },
  },

  -- Plugin para melhor integração com Git
  {
    "tpope/vim-fugitive",
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
    },
    ft = { "fugitive" },
  },

  -- Plugin adicional para commits convencionais
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>g", group = "Git" },
        { "<leader>gc", "<cmd>Git commit<cr>", desc = "Commit" },
        { "<leader>gp", "<cmd>Git push<cr>", desc = "Push" },
        { "<leader>gl", "<cmd>Git pull<cr>", desc = "Pull" },
        { "<leader>gs", "<cmd>Git status<cr>", desc = "Status" },
        { "<leader>gd", "<cmd>Gdiffsplit<cr>", desc = "Diff Split" },
        { "<leader>gb", "<cmd>Git blame<cr>", desc = "Blame" },
      },
    },
  },
}
