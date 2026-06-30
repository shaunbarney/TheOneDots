-- ── Keymaps ──────────────────────────────────────────────────────────
-- Personal bindings preserved from the old LunarVim config are marked
-- [kept]. Plugin-specific keys live in their plugin spec (lua/plugins/*).
local map = vim.keymap.set

-- Space is the leader; make sure it does nothing on its own.  [kept]
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- `?` → full keybinding cheatsheet (which-key popup of every mapping).
-- Note: this replaces `?` reverse-search; use `/` then `N` to search up.
map("n", "?", function()
  require("which-key").show({ global = true })
end, { desc = "Show all keybindings" })
-- Buffer-local keymaps only (LSP-attached buffers etc.)
map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer keybindings" })

-- Diagnostics navigation.  [kept]  (0.11 also maps these by default)
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- File tree (neo-tree).  [kept: was <C-n> NvimTreeToggle]
map("n", "<C-n>", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })

-- Fuzzy finding (telescope).  [kept]
map("n", "<C-g>", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })

-- Buffer cycling (bufferline).  [kept: H/L]
map("n", "H", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "L", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bo", "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })

-- ── Quality-of-life additions ───────────────────────────────────────
-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
-- Save / quit
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Write file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
-- Window splits (pane navigation <C-hjkl> is owned by vim-tmux-navigator,
-- so it moves seamlessly between nvim splits and tmux panes).
map("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>sc", "<C-w>c", { desc = "Close split" })
-- Keep selection when re-indenting
map("v", "<", "<gv")
map("v", ">", ">gv")
-- Move selected lines up/down
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
-- Center cursor on half-page jumps and search hits
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
