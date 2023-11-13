local plugin = {}

local dap_config = function()
    local dap = require "dap"

    local dap_ui_status_ok, dapui = pcall(require, "dapui")
    if not dap_ui_status_ok then
        return
    end

    dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        dap.repl.close()
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        dap.repl.close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        dap.repl.close()
    end

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
            -- provide the absolute path for `codelldb` command if not using the one installed using `mason.nvim`
            command = "codelldb",
            args = { "--port", "${port}" },
            -- On windows you may have to uncomment this:
            -- detached = false,
        },
    }
    dap.configurations.c = {
        {
            name = "Launch file",
            type = "codelldb",
            request = "launch",
            program = function()
                local path
                vim.ui.input({ prompt = "Path to executable: ", default = vim.loop.cwd() .. "/build/" }, function(input)
                    path = input
                end)
                vim.cmd [[redraw]]
                return path
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
    }
end

local dapui_config = function()
    require("dapui").setup {
        expand_lines = true,
        icons = { expanded = "", collapsed = "", circular = "" },
        mappings = {
            -- Use a table to apply multiple mappings
            expand = { "<CR>", "<2-LeftMouse>" },
            open = "o",
            remove = "d",
            edit = "e",
            repl = "r",
            toggle = "t",
        },
        layouts = {
            {
                elements = {
                    { id = "scopes", size = 0.33 },
                    { id = "breakpoints", size = 0.17 },
                    { id = "stacks", size = 0.25 },
                    { id = "watches", size = 0.25 },
                },
                size = 0.33,
                position = "right",
            },
            {
                elements = {
                    { id = "repl", size = 0.45 },
                    { id = "console", size = 0.55 },
                },
                size = 0.27,
                position = "bottom",
            },
        },
        floating = {
            max_height = 0.9,
            max_width = 0.5, -- Floats will be treated as percentage of your screen.
            border = vim.g.border_chars, -- Border style. Can be 'single', 'double' or 'rounded'
            mappings = {
                close = { "q", "<Esc>" },
            },
        },
    }

    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticSignError", linehl = "", numhl = "" })
end

plugin.core = {
    {
        "mfussenegger/nvim-dap",
        commit = "6b12294a57001d994022df8acbe2ef7327d30587",
        event = "VeryLazy",
    },
    {"ravenxrz/DAPInstall.nvim",
        commit = "8798b4c36d33723e7bba6ed6e2c202f84bb300de",
        lazy = true,
    },

    {
        "rcarriga/nvim-dap-ui",
        commit = "1cd4764221c91686dcf4d6b62d7a7b2d112e0b13",
        event = "VeryLazy",
    },

    {"theHamsta/nvim-dap-virtual-text"},

    config = function()
        dap_config()
        require("dap_install").setup {}
        require("dap_install").config("python", {})
        dapui_config()
    end,
}

plugin.mapping = {
    keymaps = {
        {
            tag = { key = "<leader>d",name = "Debug"},
            keymaps = {
                -- quit
                {
                    mode = "n",
                    key = "<leader>dq",
                    action = ":lua require'dapui'.close()<cr> :lua require('dap').disconnect()<cr> :lua require('dap').close()<cr><cr> :lua require('dap').repl.close()<cr>",
                    desc = string.format("%-15s", "Debug Quit") .. "F2",
                }, -- clear breakpoints
                {
                    mode = "n",
                    key = "<leader>dC",
                    action = ":lua require'dap'.clear_breakpoints()<cr>",
                    desc = string.format("%-15s", "Clear Breaks") .. "F4",
                }, -- continue
                {
                    mode = "n",
                    key = "<leader>dc",
                    action = ":lua require'dap'.continue()<cr>",
                    desc = string.format("%-15s", "Run Continue") .. "F5",
                }, -- step back
                {
                    mode = "n",
                    key = "<leader>dB",
                    action = ":lua require'dap'.step_back()<cr>",
                    desc = string.format("%-15s", "Step Back") .. "F6",
                }, {
                    mode = "n",
                    key = "<leader>da",
                    action = nil,
                    desc = "Advanced Debug",
                }, -- whole control breakpoint
                {
                    mode = "n",
                    key = "<leader>daw",
                    action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit Condition: '), vim.fn.input('Log Message: '))<cr>",
                    desc = "Advanced Break",
                }, -- condition breakpoint
                {
                    mode = "n",
                    key = "<leader>dac",
                    action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
                    desc = "Cond Break",
                }, -- breakpoint
                {
                    mode = "n",
                    key = "<leader>db",
                    action = ":lua require'dap'.toggle_breakpoint()<cr>",
                    desc = "Toggle Break",
                }, -- step over
                {
                    mode = "n",
                    key = "<leader>do",
                    action = ":lua require'dap'.step_over()<cr>",
                    desc = "Step Over",
                }, -- step into
                {
                    mode = "n",
                    key = "<leader>di",
                    action = ":lua require'dap'.step_into()<cr>",
                    desc = "Step Into",
                }, -- step out
                {
                    mode = "n",
                    key = "<leader>dO",
                    action = ":lua require'dap'.step_out()<cr>",
                    desc = "Step Out",
                }, {
                    mode = "n",
                    key = "<leader>dr",
                    action = ":lua require'dap'.repl.open()<cr>",
                    desc = "Debug Open",
                }
            }
        }
    }
}

return plugin
