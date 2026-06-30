-- ── Cyberdream colorscheme ───────────────────────────────────────────
-- The same Cyberdream palette used across alacritty/tmux/dunst. Loaded
-- eagerly (lazy=false, high priority) so it's applied before UI plugins.
-- transparent=true makes nvim's background NONE so the transparent terminal
-- (picom blur + opacity 0.88) shows through, matching the rest of the rig.
return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    variant = "default",
    transparent = true, -- let the terminal wallpaper/blur show through
    italic_comments = true,
    hide_fillchars = false,
    borderless_pickers = false, -- keep rounded borders on telescope
    terminal_colors = true,
    cache = true, -- compile highlights for faster startup
    extensions = {
      telescope = true,
      treesitter = true,
      gitsigns = true,
      notify = true,
      mini = true,
      whichkey = true,
      cmp = true, -- also styles blink.cmp
      indentblankline = true,
      lazy = true,
      dap = true,
      neotest = true,
    },
  },
  config = function(_, opts)
    require("cyberdream").setup(opts)
    vim.cmd.colorscheme("cyberdream")
  end,
}
