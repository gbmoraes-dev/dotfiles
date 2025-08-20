return {
  {
    "echasnovski/mini.icons",
    opts = {
      file = {
        ["go.mod"] = { glyph = "󰟓", hl = "HotPink" },
        ["go.sum"] = { glyph = "󰟓", hl = "MiniIconsBlue" },
        ["go.work"] = { glyph = "󰟓", hl = "MiniIconsBlue" },
      },
    },
    config = function(_, opts)
      require("mini.icons").setup(opts)
      vim.api.nvim_set_hl(0, "HotPink", {
        fg = "#FF69B4",
        bold = true,
      })
    end,
  },
}
