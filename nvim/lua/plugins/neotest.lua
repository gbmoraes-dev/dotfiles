return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "fredrikaverpil/neotest-golang", version = "*" },
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "arthur944/neotest-bun",
    },
    config = function()
      require("neotest").setup({
        status = { virtual_text = true, enabled = true, signs = true },
        output = { open_on_run = "failure", enabled = true },
        icons = {
          passed = "✅",
          failed = "❌",
          running = "⏳",
          skipped = "⏩",
          unknown = "❓",
          dap = "🐞",
        },
        adapters = {
          require("neotest-golang")({}),
          require("neotest-jest")({}),
          require("neotest-vitest")({}),
          require("neotest-bun")({}),
        },
      })
    end,
  },
}
