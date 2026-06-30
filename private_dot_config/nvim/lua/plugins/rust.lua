-- ── Rust (rustaceanvim — modern successor to the archived rust-tools) ─
-- Preserves your old <leader>C Rust group, <M-d> external docs, and the
-- K hover-actions binding. rust-analyzer comes from ~/.cargo/bin (already
-- installed); codelldb (debugging) is installed via Mason on demand.
return {
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- the plugin itself sets up the ftplugin; no setup() call
    ft = { "rust" },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          on_attach = function(_, bufnr)
            local function m(keys, cmd, desc)
              vim.keymap.set("n", keys, cmd, { buffer = bufnr, desc = desc })
            end
            -- K → rich hover actions (preserved behaviour)
            m("K", function() vim.cmd.RustLsp({ "hover", "actions" }) end, "Hover actions")
            -- <M-d> → open docs.rs for the symbol (preserved)
            m("<M-d>", function() vim.cmd.RustLsp("openDocs") end, "Open external docs")
            -- <leader>C Rust/Cargo group (preserved letters where sensible)
            m("<leader>Cr", function() vim.cmd.RustLsp("runnables") end, "Runnables")
            m("<leader>Cd", function() vim.cmd.RustLsp("debuggables") end, "Debuggables")
            m("<leader>Ct", function() vim.cmd.RustLsp("testables") end, "Testables")
            m("<leader>Cm", function() vim.cmd.RustLsp("expandMacro") end, "Expand macro")
            m("<leader>Cc", function() vim.cmd.RustLsp("openCargo") end, "Open Cargo.toml")
            m("<leader>Cp", function() vim.cmd.RustLsp("parentModule") end, "Parent module")
            m("<leader>Co", function() vim.cmd.RustLsp("openDocs") end, "External docs")
            m("<leader>CR", function() vim.cmd.RustLsp("reloadWorkspace") end, "Reload workspace")
            m("<leader>Cg", function() vim.cmd.RustLsp("crateGraph") end, "Crate graph")
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              check = { command = "clippy" }, -- clippy on save (preserved)
              procMacro = { enable = true },
              inlayHints = { lifetimeElisionHints = { enable = "always" } },
            },
          },
        },
      }
    end,
  },

  -- Cargo.toml dependency management (versions, features, popups)
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      completion = { crates = { enabled = true } },
      lsp = { enabled = true, actions = true, completion = true, hover = true },
    },
    config = function(_, opts)
      require("crates").setup(opts)
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = "Cargo.toml",
        callback = function(args)
          local crates = require("crates")
          local function m(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = desc })
          end
          m("<leader>Ci", crates.show_crate_popup, "[crates] info")
          m("<leader>Cf", crates.show_features_popup, "[crates] features")
          m("<leader>CD", crates.show_dependencies_popup, "[crates] dependencies")
          m("<leader>Cy", crates.open_repository, "[crates] open repo")
          m("<leader>Cu", crates.update_crate, "[crates] update")
        end,
      })
    end,
  },
}
