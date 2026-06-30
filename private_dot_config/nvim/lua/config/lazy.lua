-- ── lazy.nvim bootstrap ──────────────────────────────────────────────
-- Clones lazy.nvim on first launch, then imports every spec under
-- lua/plugins/*.lua. Each plugin file returns a lazy spec (table).
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = { lazy = true }, -- plugins are lazy-loaded unless they opt out
  install = { colorscheme = { "cyberdream" } },
  rocks = { enabled = false }, -- no plugin needs luarocks; skips hererocks check
  checker = { enabled = true, notify = false }, -- background update checks
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- disable unused built-in plugins for faster startup
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin", -- using neo-tree instead
      },
    },
  },
})

-- Open the lazy UI quickly
vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy plugin manager" })
