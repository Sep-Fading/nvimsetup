
-- DAP core + UI
local dap = require("dap")
local dapui = require("dapui")

require("dapui").setup()
require("nvim-dap-virtual-text").setup()

-- Auto-open/close UI
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

-- Install codelldb via Mason and register automatically
require("mason-nvim-dap").setup({
  ensure_installed = { "codelldb" },
  automatic_installation = true,
  handlers = {
    function(config)  -- default handler for all adapters
      require("mason-nvim-dap").default_setup(config)
    end,
  },
})

-- Rust launch configs
dap.configurations.rust = {
  {
    name = "Debug (cargo run)",
    type = "codelldb",
    request = "launch",
    program = function()
      -- build first so the binary exists
      vim.fn.jobstart("cargo build")
      -- pick the resulting binary (edit default path if your bin name differs)
      return vim.fn.input("Path to executable: ", "target/debug/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {}, -- e.g. { "--port", "8080" }
    env = {},  -- e.g. { RUST_LOG = "debug" }
  },
  {
    name = "Debug current test (cargo test)",
    type = "codelldb",
    request = "launch",
    program = function()
      -- builds tests; binary lands under target/debug/deps/
      vim.fn.jobstart("cargo test --no-run")
      return vim.fn.input("Test binary: ", "target/debug/deps/", "file")
    end,
    cwd = "${workspaceFolder}",
    args = {},
  },
  {
    name = "Attach to process",
    type = "codelldb",
    request = "attach",
    pid = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}
