local keymap = vim.api.nvim_set_keymap
local opt = { noremap = true }
keymap('i', 'jj', '<Esc>', opt)

keymap('n', '<c-i>', '<Esc>:so ~/.config/nvim/init.lua<CR>', opt)
keymap('n', '<C-h>', ':bprev<CR>', opt)
keymap('n', '<C-l>', ':bnext<CR>', opt)
keymap('n', '<leader>c', ':bd<CR>', opt)
keymap('n', '<leader>nh', ':noh<CR>', opt)
keymap('n', 'Y', 'y$', opt)
keymap('n', '<C-c>', ':tabclose<CR>', opt)
keymap('n', 'H', ':tabprevious<CR>', opt)
keymap('n', 'L', ':tabnext<CR>', opt)

--- Center me naughty
keymap('n', 'n', 'nzzzv', opt)
keymap('n', 'N', 'Nzzzv', opt)
keymap('n', 'J', "mzJ'z", opt)

--- Sort the UNFORGIVABLE undo
keymap('i', ',', ',<c-g>u', opt)
keymap('i', '.', '.<c-g>u', opt)
keymap('i', '!', '!<c-g>u', opt)
keymap('i', '?', '?<c-g>u', opt)
keymap('i', '<c-b>', 'mm<CR><ESC>`mi', opt)


--- Move text
keymap('v', 'J', ':m \'>+1<CR>gv=gv', opt)
keymap('v', 'K', ':m \'<-2<CR>gv=gv', opt)
keymap('i', '<C-j>', ':m .+1<CR>==', opt)
keymap('i', '<C-j>', ':m .-2<CR>==', opt)
keymap('n', '<leader>j', ':m .+1<CR>==', opt)
keymap('n', '<leader>k', ':m .-2<CR>==', opt)

