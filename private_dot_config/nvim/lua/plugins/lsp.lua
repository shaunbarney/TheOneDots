-- ── LSP (Neovim 0.12 native vim.lsp.config + Mason) ──────────────────
-- Servers chosen for the sovra monorepo:
--   vtsls ........ TypeScript/React (frontend + wa-bridge, 3k+ TS files)
--   eslint ....... ESLint v9 flat config; fixes on save (matches `eslint --fix`)
--   pyright ...... Python 3.12 types (FastAPI backend)
--   ruff ......... Python lint + import sorting (sovra uses ruff)
--   tailwindcss .. Tailwind 4
--   yamlls ....... agent YAML configs / docker-compose
--   jsonls ....... package.json/tsconfig (+ schemastore)
--   sqlls ........ Supabase SQL migrations
--   bashls, dockerls, marksman, cssls, lua_ls
-- (rust_analyzer is owned by rustaceanvim in lua/plugins/rust.lua.)
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "mason-org/mason-lspconfig.nvim",
    "saghen/blink.cmp",
    "b0o/schemastore.nvim",
  },
  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Global defaults merged into every server config
    vim.lsp.config("*", { capabilities = capabilities })

    -- ── Per-server overrides ──────────────────────────────────────────
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
          hint = { enable = true },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "standard",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "openFilesOnly", -- huge repo: don't index everything
          },
        },
      },
    })

    -- ruff: lint + format/imports only; let pyright own hover & types.
    vim.lsp.config("ruff", {
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    })

    vim.lsp.config("vtsls", {
      settings = {
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          inlayHints = {
            parameterNames = { enabled = "literals" },
            variableTypes = { enabled = false },
            propertyDeclarationTypes = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
          },
        },
      },
      -- eslint owns formatting for JS/TS; disable tsserver's formatter.
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })

    vim.lsp.config("eslint", {
      -- Fix all auto-fixable problems on save (matches sovra's `eslint --fix`).
      on_attach = function(_, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            -- server-agnostic: ask the eslint LSP to apply its fix-all action
            vim.lsp.buf.code_action({
              context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
              apply = true,
            })
          end,
        })
      end,
    })

    vim.lsp.config("jsonls", {
      settings = {
        json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
      },
    })

    vim.lsp.config("yamlls", {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = "" },
          schemas = require("schemastore").yaml.schemas(),
          keyOrdering = false,
        },
      },
    })

    -- ── Auto-enable installed servers ─────────────────────────────────
    -- automatic_enable calls vim.lsp.enable() for every server Mason has
    -- installed; our config(*)/per-server overrides above are merged in.
    require("mason-lspconfig").setup({
      automatic_enable = true,
    })

    -- ── Ensure all servers + tools are installed (deterministic) ──────
    -- Installed directly via the Mason registry (mason package names), which
    -- is version-independent and works headless. is_installed() makes this a
    -- no-op once everything is present, so it adds ~nothing to later startups.
    local ensure = {
      -- LSP servers. (No SQL LSP: sql-language-server crashes without a built
      --  sqlite3 native binding, which this machine's npm allow-scripts policy
      --  blocks; sqls needs a DB-connection config to be useful. SQL files get
      --  treesitter highlighting. Add sqls + ~/.config/sqls/config.yml later if
      --  you want schema-aware Supabase/Postgres completion.)
      "lua-language-server", "pyright", "ruff", "vtsls", "eslint-lsp",
      "tailwindcss-language-server", "yaml-language-server", "json-lsp",
      "bash-language-server", "dockerfile-language-server",
      "marksman", "css-lsp",
      -- formatters + debug adapters (rust_analyzer/codelldb-for-rust via rustaceanvim)
      "stylua", "prettierd", "shfmt", "debugpy", "codelldb",
    }
    local mr = require("mason-registry")
    local function install_missing()
      for _, name in ipairs(ensure) do
        local ok, pkg = pcall(mr.get_package, name)
        if ok and not pkg:is_installed() then
          pkg:install()
        end
      end
    end
    if mr.refresh then mr.refresh(install_missing) else install_missing() end

    -- ── Buffer-local LSP keymaps (on attach) ──────────────────────────
    -- 0.11+ already maps grn (rename), gra (code action), grr (references),
    -- gri (implementation), K (hover). These add telescope-powered nav and
    -- a discoverable <leader>l "LSP" group.
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
      callback = function(args)
        local buf = args.buf
        local function m(keys, fn, desc, mode)
          vim.keymap.set(mode or "n", keys, fn, { buffer = buf, desc = desc })
        end
        local tb = require("telescope.builtin")
        m("gd", tb.lsp_definitions, "Goto definition")
        m("gD", vim.lsp.buf.declaration, "Goto declaration")
        m("gy", tb.lsp_type_definitions, "Goto type definition")
        m("gr", tb.lsp_references, "References")
        m("gI", tb.lsp_implementations, "Implementations")
        m("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
        m("<leader>la", vim.lsp.buf.code_action, "Code action", { "n", "v" })
        m("<leader>ls", tb.lsp_document_symbols, "Document symbols")
        m("<leader>lS", tb.lsp_dynamic_workspace_symbols, "Workspace symbols")
        m("<leader>ld", tb.diagnostics, "Workspace diagnostics")

        -- Inlay hints toggle (on by default where the server supports them)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = buf })
          m("<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
          end, "Toggle inlay hints")
        end
      end,
    })
  end,
}
