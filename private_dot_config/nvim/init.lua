-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  Neovim — modern config (Neovim 0.12+)                             ║
-- ║  Cyberdream theme · native Claude Code · tuned for the sovra stack ║
-- ║  Layout:  lua/config/*  (options, keymaps, autocmds, lazy boot)    ║
-- ║           lua/plugins/* (one file per concern, auto-imported)      ║
-- ╚══════════════════════════════════════════════════════════════════╝

-- Leader keys MUST be set before lazy.nvim loads so plugin `keys = {}`
-- specs that use <leader> register against the right key. Space = leader
-- (matches the old LunarVim setup).
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy") -- bootstraps lazy.nvim + imports lua/plugins/*
require("config.keymaps") -- preserved personal bindings + global maps
require("config.autocmds")
require("config.setup").setup() -- auto-install tools + health check on open
