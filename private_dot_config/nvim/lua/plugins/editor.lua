-- ── Editor: tree, git, which-key, surround, pairs, tmux nav ──────────
return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree", -- <C-n> (in keymaps.lua) toggles it
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>E", "<cmd>Neotree reveal<cr>", desc = "Reveal file in tree" },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = true },
      },
      window = { width = 34 },
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = {
          symbols = {
            added = "", modified = "", deleted = "", renamed = "",
            untracked = "", ignored = "", unstaged = "", staged = "", conflict = "",
          },
        },
      },
    },
  },

  -- Git signs + hunk actions
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" },
        topdelete = { text = "" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = buf, desc = desc })
        end
        m("]h", gs.next_hunk, "Next hunk")
        m("[h", gs.prev_hunk, "Prev hunk")
        m("<leader>gs", gs.stage_hunk, "Stage hunk")
        m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk")
        m("<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        m("<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
        m("<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },

  -- Lazygit popup (in addition to tmux's prefix+g)
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" } },
  },

  -- Keybinding hints + group labels
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      win = { border = "rounded" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>a", group = "AI / Claude" },
        { "<leader>b", group = "Buffers" },
        { "<leader>c", group = "Code / lang" },
        { "<leader>C", group = "Rust / Cargo" },
        { "<leader>d", group = "Debug / Test" },
        { "<leader>f", group = "Find" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "LSP" },
        { "<leader>s", group = "Splits" },
        { "<leader>x", group = "Diagnostics" },
      })
    end,
  },

  -- Surround (replaces the old tpope/vim-surround)
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Auto pairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- TODO / FIXME / NOTE highlighting + search
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    },
  },

  -- Seamless navigation between nvim splits and tmux panes (<C-hjkl>).
  -- Mirrors christoomey/vim-tmux-navigator already in the tmux config.
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp", "TmuxNavigateRight",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Nav left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Nav down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Nav up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Nav right" },
    },
  },
}
