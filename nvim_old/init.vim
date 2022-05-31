syntax on

let mapleader = " "


call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update

" Plebvim lsp Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'mattn/emmet-vim'

" Searching
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
"
" telescope requirements...
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'

" Style
Plug 'tyrannicaltoucan/vim-deep-space'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lilydjwg/colorizer'

" Themes
Plug 'morhetz/gruvbox'

" thon
Plug 'vim-python/python-syntax'

" Latex
Plug 'lervag/vimtex'


" File explorer
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Programming helpers
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'

" General
Plug 'tpope/vim-repeat'

" HTML
Plug 'mattn/emmet-vim'

" Snippets
" Plug 'SirVer/ultisnips'
"   React
" Plug 'mlaursen/vim-react-snippets'

" Coc
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Git
Plug 'tpope/vim-fugitive'
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

" Lua

lua << EOF
require'lspconfig'.pyright.setup{}
require'lspconfig'.gopls.setup{}
EOF

inoremap jj <Esc>
" inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

nnoremap <C-h> :bprev<CR>
nnoremap <C-l> :bnext<CR>
nnoremap <C-c> :bd<CR>
nnoremap <leader>nh :noh<CR>
nnoremap <leader>ss :s ~/.config/nvim/init.vim

imap <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u
nmap <c-f> [s1z=<c-o>

" Prime remaps
" Behave like you should, bitch
nnoremap Y y$

" Center me naughty
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ'z

" Sort the UNFORGIVABLE undo
inoremap , ,<c-g>u
inoremap . .<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

" Jumplist mutations
nnoremap <expr> k (v:count > 5 ? "m'" . v:count : "") . 'k'
nnoremap <expr> j (v:count > 5 ? "m'" . v:count : "") . 'j'

" Move text
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
inoremap <C-j> :m .+1<CR>==
inoremap <C-j> :m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==
nnoremap <leader>i <ESC>:so ~/.config/nvim/init.vim<CR>
nnoremap <c-i> <ESC>:so ~/.config/nvim/init.vim<CR>
