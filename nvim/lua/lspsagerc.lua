local saga = require 'lspsaga'

saga.init_lsp_saga {
  error_sign = '',
  warn_sign = '',
  hint_sign = '',
  infor_sign = '',
  border_style = "round",
}


local keymap = vim.api.nvim_set_keymap
local opt = { noremap = true }

keymap('n', '<leader><C-j>', ':Lspsaga diagnostic_jump_next<CR>', opt)
keymap('n', '<leader>K', '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>', opt)
keymap('n', '<leader>gh', ':Lspsaga lsp_finder<CR>', opt)
keymap('n', '<leader>gp', ':Lspsaga preview_definition<CR>', opt)
