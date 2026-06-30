-- ── Treesitter: syntax, indentation, textobjects ─────────────────────
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- stable API (ensure_installed + highlight=true)
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    main = "nvim-treesitter.configs",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      ensure_installed = {
        -- config / editing nvim itself
        "lua", "luadoc", "vim", "vimdoc", "query",
        -- sovra backend
        "python", "sql", "toml",
        -- sovra frontend + wa-bridge
        "typescript", "tsx", "javascript", "json", "jsonc", "css", "html",
        -- infra / docs / agent configs
        "yaml", "dockerfile", "bash", "markdown", "markdown_inline",
        -- personal: rust + go
        "rust", "go",
        -- git
        "gitcommit", "git_rebase", "gitignore", "diff", "regex",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
        },
      },
    },
  },
}
