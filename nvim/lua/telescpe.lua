local keymap = vim.api.nvim_set_keymap
local opt = { noremap = true }

keymap('n', '<leader>ff', '<Esc>:Telescope find_files<cr>', opt)
keymap('n', '<leader>fg', '<Esc>:Telescope live_grep<cr>', opt)
keymap('n', '<leader>fb', '<Esc>:Telescope buffers<cr>', opt)
keymap('n', '<leader>fh', '<Esc>:Telescope help_tags<cr>', opt)
