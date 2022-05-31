" emmet html
let g:user_emmet_leader_key=',,'
let g:user_emmet_settings = {
\  'javascript' : {
\      'extends' : 'jsx',
\  },
\}
autocmd FileType html,css,javascript,jsx,typescript,tsx EmmetInstall
inoremap ,. <Esc>V:s/class/className/g<cr>f>:noh<cr>a<cr><Esc>O<tab>
