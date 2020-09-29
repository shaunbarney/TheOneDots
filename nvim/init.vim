syntax on

set clipboard=unnamed
set number
set relativenumber
set tabstop     =4
set softtabstop =4
set shiftwidth  =4
set expandtab
set spelllang   =en
set colorcolumn =80
set encoding=UTF-8
highlight ColorColumn ctermbg=0 guibg=lightgrey

let mapleader = " "

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Typescript plugins
Plug 'peitalin/vim-jsx-typescript'

" Html snippets
Plug 'mattn/emmet-vim'
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
Plug 'neoclide/coc-snippets'
Plug 'mlaursen/vim-react-snippets'

Plug 'junegunn/goyo.vim'
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
Plug 'tpope/vim-fugitive'
Plug 'chrisbra/csv.vim'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'pangloss/vim-javascript'
Plug  'chemzqm/vim-jsx-improve'
Plug 'ryanoasis/vim-devicons'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

colorscheme gruvbox

" Remaps
inoremap jj <Esc>
"inoremap clg console.log()<Esc>ji
nnoremap <C-h> :bprev<CR>
nnoremap <C-l> :bnext<CR>
nnoremap <C-c> :bd<CR>
nnoremap <leader>nh <Esc>:noh<cr>

" Snippets
let g:UltiSnipsExpandTrigger = "<nop>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" emmet html
let g:user_emmet_leader_key=',,'
let g:user_emmet_settings = {
\  'javascript' : {
\      'extends' : 'jsx',
\  },
\}
autocmd FileType html,css,javascript.jsx EmmetInstall
inoremap ,. <Esc>V:s/class/className/g<cr>f>:noh<cr>a<cr><Esc>O<tab>

" Airline themes
let g:airline_theme='violet'
"let g:NERDCustomDelimiters={
	"\ 'javascript': { 'left': '//', 'right': '', 'leftAlt': '{/*', 'rightAlt': '*/}' },
"\}
let g:NERDCustomDelimiters = {'javascriptreact': { 'left': '//', 'right': '', 'leftAlt': '{/*', 'rightAlt': '*/}' }}

" Package imports
source ~/.config/nvim/fzf.vim
source ~/.config/nvim/coc.vim
source ~/.config/nvim/nerdtree.vim
source ~/.config/nvim/coc-snippets.vim
"source ~/.config/nvim/closetag.vimj
source  ~/.config/nvim/functions.vim
