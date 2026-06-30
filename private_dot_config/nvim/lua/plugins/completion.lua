-- ── Completion: blink.cmp (LSP/snippets/path/buffer only) ────────────
-- No AI completion here. Claude Code (lua/plugins/claude.lua) is the ONLY
-- AI assistant in this config — Copilot was removed by request. blink is a
-- plain LSP/snippet completion engine, not an AI source.
return {
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*", -- ships a prebuilt Rust fuzzy matcher; no build step
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "default", -- <C-y> accept, <C-n>/<C-p> select, <C-e> hide
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
