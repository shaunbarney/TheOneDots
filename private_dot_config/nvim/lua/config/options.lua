-- ── Editor options ───────────────────────────────────────────────────
local opt = vim.opt

-- Line numbers: relative + absolute current line (preserved from old config)
opt.number = true
opt.relativenumber = true

-- UI
opt.termguicolors = true -- 24-bit colour (required for cyberdream)
opt.signcolumn = "yes" -- always show sign column (no text shift)
opt.cursorline = true
opt.scrolloff = 8 -- keep context around the cursor
opt.sidescrolloff = 8
opt.wrap = false
opt.pumheight = 12 -- popup menu height
opt.showmode = false -- mode shown in statusline instead
opt.splitright = true
opt.splitbelow = true
opt.winborder = "rounded" -- rounded borders for floating windows (0.11+)

-- Indentation (4-space default; filetype plugins/LSP refine per-language)
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Files / persistence
opt.undofile = true -- persistent undo across sessions
opt.swapfile = false
opt.backup = false
opt.updatetime = 200 -- faster CursorHold / diagnostics
opt.timeoutlen = 300 -- which-key responsiveness

-- Behaviour
opt.mouse = "a"
opt.clipboard = "unnamedplus" -- share the system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true -- prompt instead of failing on unsaved changes
opt.virtualedit = "block"
opt.inccommand = "split" -- live preview of :substitute

-- Diagnostics: clean, modern presentation
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌶",
    },
  },
})
