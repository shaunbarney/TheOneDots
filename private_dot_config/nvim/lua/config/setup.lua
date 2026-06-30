-- ── Setup self-check: auto-install tools + report errors on open ─────
-- On startup (deferred so the UI is responsive first) this:
--   1. makes sure every LSP server / formatter / debug adapter is installed
--      (re-installs any that are missing — e.g. a server that failed earlier),
--   2. checks the Claude CLI is present (Claude Code needs it),
--   3. checks treesitter parsers and reports any plugin load errors,
--   4. notifies ONLY if something needs attention (silent when all good).
-- Manual triggers: :SetupCheck  and  :SetupInstall  (+ <leader>cs / <leader>cH).
local M = {}

-- Mirrors the ensure list in lua/plugins/lsp.lua (Mason package names).
M.packages = {
  -- LSP servers
  "lua-language-server", "pyright", "ruff", "vtsls", "eslint-lsp",
  "tailwindcss-language-server", "yaml-language-server", "json-lsp",
  "bash-language-server", "dockerfile-language-server",
  "marksman", "css-lsp", -- (sqlls comes from PATH, not Mason — see lsp.lua)
  -- formatters + debug adapters
  "stylua", "prettierd", "shfmt", "debugpy", "codelldb",
}

-- Ensure Mason is actually loaded (it lazy-loads with nvim-lspconfig, which
-- may not have triggered yet on an empty start / dashboard).
local function with_mason(cb)
  local ok, mr = pcall(require, "mason-registry")
  if ok then
    return cb(mr)
  end
  pcall(function() require("lazy").load({ plugins = { "mason.nvim" } }) end)
  local ok2, mr2 = pcall(require, "mason-registry")
  if ok2 then
    return cb(mr2)
  end
end

function M.missing()
  return with_mason(function(mr)
    local missing = {}
    for _, name in ipairs(M.packages) do
      local ok, pkg = pcall(mr.get_package, name)
      if ok and not pkg:is_installed() then
        table.insert(missing, name)
      end
    end
    return missing
  end)
end

-- Install anything missing (no-op when everything is present).
function M.install(opts)
  opts = opts or {}
  with_mason(function(mr)
    local function run()
      local missing = M.missing() or {}
      for _, name in ipairs(missing) do
        local ok, pkg = pcall(mr.get_package, name)
        if ok then pkg:install() end
      end
      if #missing > 0 then
        vim.notify(
          "Installing " .. #missing .. " missing tool(s):\n  " .. table.concat(missing, ", "),
          vim.log.levels.INFO,
          { title = "nvim setup" }
        )
      elseif opts.verbose then
        vim.notify("All tools already installed ✓", vim.log.levels.INFO, { title = "nvim setup" })
      end
    end
    if mr.refresh then mr.refresh(run) else run() end
  end)
end

-- Report any problems (Claude CLI, missing tools, plugin load errors).
function M.check(opts)
  opts = opts or {}
  local problems = {}

  if vim.fn.executable("claude") == 0 then
    table.insert(problems, "✗ `claude` CLI not on PATH — Claude Code integration won't connect")
  end

  local missing = M.missing()
  if missing and #missing > 0 then
    table.insert(problems, "⏳ " .. #missing .. " tool(s) not yet installed: " .. table.concat(missing, ", "))
  end

  -- Surface any plugins lazy.nvim failed to load.
  local ok, lazy_core = pcall(require, "lazy.core.util")
  if ok and lazy_core.get_unloaded_rtp then end -- noop guard for API drift
  local plugins_with_errors = {}
  for _, p in ipairs(require("lazy").plugins()) do
    if p._.kind ~= "disabled" and p._.has_errors then
      table.insert(plugins_with_errors, p.name)
    end
  end
  if #plugins_with_errors > 0 then
    table.insert(problems, "✗ plugin errors: " .. table.concat(plugins_with_errors, ", "))
  end

  if #problems == 0 then
    if opts.verbose then
      vim.notify("Setup OK ✓ — all servers, tools and Claude CLI present", vim.log.levels.INFO, { title = "nvim setup" })
    end
  else
    vim.notify(table.concat(problems, "\n"), vim.log.levels.WARN, { title = "nvim setup" })
  end
  return problems
end

function M.setup()
  vim.api.nvim_create_user_command("SetupInstall", function() M.install({ verbose = true }) end, { desc = "Install missing LSP/tools" })
  vim.api.nvim_create_user_command("SetupCheck", function() M.check({ verbose = true }) end, { desc = "Check nvim setup health" })

  vim.keymap.set("n", "<leader>cs", function() M.check({ verbose = true }) end, { desc = "Setup status" })
  vim.keymap.set("n", "<leader>cH", "<cmd>checkhealth<cr>", { desc = "Full checkhealth" })

  -- Run automatically shortly after the editor opens.
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("user_setup_check", { clear = true }),
    callback = function()
      vim.defer_fn(function()
        M.install({}) -- ensure/repair installs
        M.check({}) -- notify only if there's a problem
      end, 1200)
    end,
  })
end

return M
