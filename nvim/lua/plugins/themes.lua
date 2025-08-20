-- colorschemes config
return {

  {
    "catppuccin/nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      terminal_colors = true,
    },
  },

  {
    "jwbaldwin/oscura.nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
