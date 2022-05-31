-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'


  -- CMP
  use 'kabouzeid/nvim-lspinstall'
  use 'tjdevries/nlua.nvim'
  use {
      'neovim/nvim-lspconfig',
      'williamboman/nvim-lsp-installer',
  }

  use { 'nvim-lua/completion-nvim' }
  use "onsails/lspkind-nvim"
  use 'euclidianAce/BetterLua.vim'

  use 'tjdevries/manillua.nvim'
  use {

  "hrsh7th/nvim-cmp",
  requires = {
      "hrsh7th/cmp-buffer", "hrsh7th/cmp-nvim-lsp",
      'quangnguyen30192/cmp-nvim-ultisnips', 'hrsh7th/cmp-nvim-lua',
      'octaltree/cmp-look', 'hrsh7th/cmp-path', 'hrsh7th/cmp-calc',
      'f3fora/cmp-spell', 'hrsh7th/cmp-emoji', 'hrsh7th/cmp-cmdline'
  }
  }
  use {
    'tzachar/cmp-tabnine',
    run = './install.sh',
    requires = 'hrsh7th/nvim-cmp'
}

  use 'nvim-treesitter/nvim-treesitter'

  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
        {"nvim-lua/plenary.nvim"},
        {"nvim-treesitter/nvim-treesitter"}
    }
}

--   -- telescope requirements...
   use {
     'nvim-telescope/telescope.nvim',
     requires = { {'nvim-lua/plenary.nvim'} }
   }
   use 'nvim-lua/popup.nvim'
   use 'nvim-lua/plenary.nvim'
   use 'nvim-telescope/telescope-fzy-native.nvim'

--   -- Themes
   use 'morhetz/gruvbox'
   use 'vim-airline/vim-airline'
   use 'vim-airline/vim-airline-themes'
   use 'lilydjwg/colorizer'
   use 'joshdick/onedark.vim'
   use 'sheerun/vim-polyglot'
   use 'folke/tokyonight.nvim'
   use {
     'nvim-lualine/lualine.nvim',
     requires = {'kyazdani42/nvim-web-devicons', opt = true}
   }

--   -- File tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require'nvim-tree'.setup {} end
  }




--   -- Style
  use 'tyrannicaltoucan/vim-deep-space'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'
  use 'lilydjwg/colorizer'

--   -- Programming helpers
   use 'sbdchd/neoformat'
   use 'jiangmiao/auto-pairs'
   use 'tpope/vim-surround'
   use 'tpope/vim-fugitive'
   use 'glepnir/lspsaga.nvim'
   use 'terrortylor/nvim-comment'

   -- Snippets
   use { 'honza/vim-snippets' }
   use { 'SirVer/ultisnips' }

   use {'hrsh7th/vim-vsnip'}
   use {'hrsh7th/vim-vsnip-integ'}


-- -- General
  use 'tpope/vim-repeat'

-- -- HTML
  use 'mattn/emmet-vim'

   -- Golang
   use 'ray-x/go.nvim'

end)
