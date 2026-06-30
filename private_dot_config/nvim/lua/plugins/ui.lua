-- ── UI: statusline, bufferline, snacks niceties ──────────────────────
return {
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Statusline (cyberdream theme)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "cyberdream",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "dashboard", "neo-tree" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype", "encoding" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Bufferline (your H / L cycle between buffers)
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        separator_style = "slant",
        offsets = {
          { filetype = "neo-tree", text = "Explorer", highlight = "Directory", separator = true },
        },
      },
    },
  },

  -- Indent guides + scope (via mini for cyberdream integration)
  {
    "echasnovski/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    opts = { symbol = "│", options = { try_as_border = true } },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "neo-tree", "dashboard", "lazy", "mason", "Trouble", "checkhealth" },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },

  -- folke/snacks: dashboard, notifier, bigfile, input, quickfile.
  -- (Also the runtime backend for claudecode.nvim's terminal split.)
  {
    "folke/snacks.nvim",
    priority = 900,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      input = { enabled = true },
      image = { enabled = false }, -- alacritty has no kitty-graphics; avoid the noise
      indent = { enabled = false }, -- mini.indentscope owns this
      dashboard = {
        enabled = true,
        preset = {
          header = [[
   ▟█████▙   Neovim · cyberdream · Claude
  ▟███████▙  ───────────────────────────
  ▜███████▛  sovra · agents · all day
   ▜█████▛   ]],
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
    keys = {
      { "<leader>n", function() require("snacks").notifier.show_history() end, desc = "Notifications" },
      { "<leader>cd", function() require("snacks").dashboard() end, desc = "Dashboard" },
    },
  },
}
