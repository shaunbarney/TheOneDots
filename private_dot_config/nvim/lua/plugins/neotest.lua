-- ── Testing (neotest) ────────────────────────────────────────────────
-- Adapters: python (pytest — sovra backend) and vitest (sovra frontend).
-- The <leader>d{m,M,f,F,S} bindings are preserved verbatim from the old
-- LunarVim config.
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-neotest/neotest-python",
    "marilari88/neotest-vitest",
  },
  keys = {
    { "<leader>dm", function() require("neotest").run.run() end, desc = "Test nearest" },
    { "<leader>dM", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test nearest (DAP)" },
    { "<leader>df", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test file" },
    { "<leader>dF", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Test file (DAP)" },
    { "<leader>dS", function() require("neotest").summary.toggle() end, desc = "Test summary" },
    { "<leader>dn", function() require("neotest").output.open({ enter = true }) end, desc = "Test output" },
    { "<leader>dl", function() require("neotest").output_panel.toggle() end, desc = "Test output panel" },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python")({
          runner = "pytest",
          dap = { justMyCode = false, console = "integratedTerminal" },
          args = { "--quiet" },
        }),
        require("neotest-vitest"),
      },
      status = { virtual_text = true },
      output = { open_on_run = true },
    })
  end,
}
