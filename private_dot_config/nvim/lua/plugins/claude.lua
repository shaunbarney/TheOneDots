-- ── Native Claude Code integration ───────────────────────────────────
-- coder/claudecode.nvim is a pure-Lua implementation of the same WebSocket
-- MCP protocol the official VS Code / JetBrains extensions use. It talks to
-- the `claude` CLI (installed at ~/.nvm/.../bin/claude) and gives you:
--   • a Claude terminal split inside nvim
--   • @-mention the current file / visual selection as context
--   • in-editor diff view of Claude's edits with accept/deny
--   • model selection, resume / continue sessions
-- All under the <leader>a ("AI") prefix.
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    -- Use Neovim's built-in terminal (no runtime snacks requirement);
    -- snacks stays a dep for its other niceties used across the config.
    terminal = {
      split_side = "right",
      split_width_percentage = 0.35,
      provider = "snacks",
    },
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
      open_in_current_tab = true,
    },
  },
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },
  keys = {
    { "<leader>a", nil, desc = "AI / Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude session" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last session" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer as context" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file from tree",
      ft = { "neo-tree", "NvimTree", "oil", "minifiles", "snacks_picker_list" },
    },
    -- Diff review of Claude's proposed edits
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude's diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude's diff" },
    { "<leader>ax", "<cmd>ClaudeCodeCloseAllDiffs<cr>", desc = "Close all diffs" },
  },
}
