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
set cursorline
set hidden
set smartcase
set ignorecase
set scrolloff=8
set signcolumn=yes

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType typescript setlocal ts=2 sts=2 sw=2 expandtab

highlight ColorColumn ctermbg=0 guibg=lightgrey

let mapleader = " "

call plug#begin('~/.vim/plugged')
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Typescript plugins
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'

" Html snippets
Plug 'mattn/emmet-vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'neoclide/coc-snippets'
Plug 'mlaursen/vim-react-snippets'
Plug 'junegunn/goyo.vim'
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
Plug 'tpope/vim-fugitive'
Plug 'chrisbra/csv.vim'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'pangloss/vim-javascript'
Plug 'chemzqm/vim-jsx-improve'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'jparise/vim-graphql'
Plug 'uarun/vim-protobuf'
Plug 'wadackel/vim-dogrun'
Plug 'lilydjwg/colorizer'

Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'tyrannicaltoucan/vim-deep-space'
call plug#end()

set background=dark
set termguicolors
colorscheme deep-space
let g:deepspace_italics=1
let g:airline_theme='deep_space'

" Remaps
inoremap jj <Esc>
"inoremap clg console.log()<Esc>ji
nnoremap <C-h> :bprev<CR>
nnoremap <C-l> :bnext<CR>
nnoremap <C-c> :bd<CR>
nnoremap <leader>nh <Esc>:noh<cr>

"vnoremap <leader>y "+y
vnoremap <leader> y: call system("xclip -i", getreg("\""))<CR>
noremap <leader> p :r !xclip -o <CR>
nnoremap <leader>s :source ~/.config/nvim/init.vim<CR>

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

" JavaScript
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1
augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
augroup END

" Package imports
source ~/TheOneDots/nvim/fzf.vim
source ~/TheOneDots/nvim/coc.vim
source ~/TheOneDots/nvim/nerdtree.vim
source ~/TheOneDots/nvim/coc-snippets.vim
"source ~/.config/nvim/closetag.vimj
source  ~/TheOneDots/nvim/functions.vim
source ~/TheOneDots/nvim/go.vim

" configudations that use nvim 0.5
source ~/TheOneDots/nvim/nvim_5/telescope.vim
