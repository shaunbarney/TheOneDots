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
set scrolloff=15
set signcolumn=yes

au BufRead,BufNewFile *.tex setlocal textwidth=80
au BufRead,BufNewFile *.tex setlocal spell
au BufRead,BufNewFile *.tex setlocal spelllang=en_gb
