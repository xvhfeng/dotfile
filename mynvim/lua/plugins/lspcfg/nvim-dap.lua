local plugin = {}

plugin.core = {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        {"mfussenegger/nvim-dap"}, {"theHamsta/nvim-dap-virtual-text"}
    },

    init = function() -- Specifies code to run before this plugin is loaded.
    
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        local dap, dapui = require('dap'), require('dapui')
        vim.fn.sign_define('DapBreakpoint', {
            text = ' ',
            texthl = 'Error',
            linehl = '',
            numhl = ''
        })
        vim.fn.sign_define('DapStopped', {
            text = '➤',
            texthl = 'DiagnosticInfo',
            linehl = '',
            numhl = ''
        })
        vim.fn.sign_define('DapBreakpointCondition', {
            text = '鬒',
            texthl = 'Todo',
            linehl = '',
            numhl = ''
        })
        vim.fn.sign_define('DapBreakpointRejected', {
            text = ' ',
            texthl = 'Error',
            linehl = '',
            numhl = ''
        })
        vim.fn.sign_define('DapLogPoint', {
            text = ' ',
            texthl = 'DiagnosticHint',
            linehl = '',
            numhl = ''
        })
        dap.listeners.after.event_initialized['dapui_config'] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated['dapui_config'] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited['dapui_config'] = function()
            dapui.close()
        end

        -- dap.defaults.fallback.terminal_win_cmd = 'resize 10'
        dap.defaults.fallback.terminal_win_cmd = 'botright ' ..
        math.floor(
            vim.fn
            .winheight(
                vim.fn.winnr()) / 6) ..
        'new'
        require("dapui").setup({
            icons = {collapsed = "", current_frame = "", expanded = ""},
            mappings = {
                -- Use a table to apply multiple mappings
                expand = {"<CR>", "<2-LeftMouse>"},
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r"
            },
            -- expand_lines = vim.fn.has("nvim-0.7"),
            expand_lines = false,
            controls = {
                element = "repl",
                enabled = true,
                icons = {
                    disconnect = "",
                    pause = "",
                    play = "",
                    run_last = "",
                    step_back = "",
                    step_into = "",
                    step_out = "",
                    step_over = "",
                    terminate = ""
                }
            },
            layouts = {
                {
                    -- open_on_start = true,
                    -- You can change the order of elements in the sidebar
                    elements = {
                        -- Provide as ID strings or tables with "id" and "size" keys
                        {id = "stacks", size = 0.20},
                        {id = "breakpoints", size = 0.20}, {
                            id = "scopes",
                            size = 0.40 -- Can be float or integer > 1
                        }, {id = "watches", size = 0.20}
                    },
                    size = math.floor(vim.fn.winwidth(vim.fn.winnr()) / 4),
                    position = "left" -- Can be "left", "right", "top", "bottom"
                }, {
                    elements = {
                        {id = "console", size = 0.5}, {id = "repl", size = 0.5}
                    },
                    size = math.floor(vim.fn.winheight(vim.fn.winnr()) / 6),
                    position = "bottom"
                }
            },
            floating = {
                max_height = nil, -- These can be integers or a float between 0 and 1.
                max_width = nil, -- Floats will be treated as percentage of your screen.
                mappings = {close = {"q", "<Esc>"}}
            },
            windows = {indent = 1}
        })

        require("nvim-dap-virtual-text").setup {
            enabled = true, -- enable this plugin (the default)
            enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
            highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
            highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
            show_stop_reason = true, -- show stop reason when stopped for exceptions
            commented = false, -- prefix virtual text with comment string
            only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
            all_references = false, -- show virtual text on all all references of the variable (not only definitions)
            filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
            -- experimental features:
            virt_text_pos = 'eol', -- position of virtual text, see `:h nvim_buf_set_extmark()`
            all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
            virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
            virt_text_win_col = nil -- position the virtual text at a fixed window column (starting from the first text column) ,
            -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
        }
    end

}

plugin.mapping = {
    keys = {
        -- quit
        {
            mode = "n",
            key = {"<leader>", "d", "q"},
            action = ":lua require'dapui'.close()<cr> :lua require('dap').disconnect()<cr> :lua require('dap').close()<cr><cr> :lua require('dap').repl.close()<cr>",
            desc = string.format("%-15s", "Debug Quit") .. "F2",
        }, {
            mode = "n",
            key = {"<F2>"},
            action = ":lua require'dapui'.close()<cr> :lua require('dap').disconnect()<cr> :lua require('dap').close()<cr><cr> :lua require('dap').repl.close()<cr>",
            desc = "Debug Quit",
        }, -- clear breakpoints
        {
            mode = "n",
            key = {"<leader>", "d", "C"},
            action = ":lua require'dap'.clear_breakpoints()<cr>",
            desc = string.format("%-15s", "Clear Breaks") .. "F4",
        }, {
            mode = "n",
            key = {"<F4>"},
            action = ":lua require'dap'.clear_breakpoints()<cr>",
            desc = "Clear Breaks",
        }, -- continue
        {
            mode = "n",
            key = {"<leader>", "d", "c"},
            action = ":lua require'dap'.continue()<cr>",
            desc = string.format("%-15s", "Run Continue") .. "F5",
        }, {
            mode = "n",
            key = {"<F5>"},
            action = ":lua require'dap'.continue()<cr>",
            desc = "Run Continue",
        }, -- step back
        {
            mode = "n",
            key = {"<leader>", "d", "B"},
            action = ":lua require'dap'.step_back()<cr>",
            desc = string.format("%-15s", "Step Back") .. "F6",
        }, {
            mode = "n",
            key = {"<F6>"},
            action = ":lua require'dap'.step_back()<cr>",
            desc = "Step Back",
        }, {
            mode = "n",
            key = {"<leader>", "d", "a"},
            action = nil,
            desc = "Advanced Debug",
        }, -- whole control breakpoint
        {
            mode = "n",
            key = {"<leader>", "d", "a", "w"},
            action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit Condition: '), vim.fn.input('Log Message: '))<cr>",
            desc = string.format("%-15s", "Advanced Break") .. "F7",
        }, {
            mode = "n",
            key = {"<F7>"},
            action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '), vim.fn.input('Hit Condition: '), vim.fn.input('Log Message: '))<cr>",
            desc = "Advanced Break",
        }, -- condition breakpoint
        {
            mode = "n",
            key = {"<leader>", "d", "a", "c"},
            action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
            desc = string.format("%-15s", "Cond Break") .. "F8",
        }, {
            mode = "n",
            key = {"<F8>"},
            action = ":lua require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>",
            desc = "Cond Break",
        }, -- breakpoint
        {
            mode = "n",
            key = {"<leader>", "d", "b"},
            action = ":lua require'dap'.toggle_breakpoint()<cr>",
            desc = string.format("%-15s", "Toggle Break") .. "F9",
        }, {
            mode = "n",
            key = {"<F9>"},
            action = ":lua require'dap'.toggle_breakpoint()<cr>",
            desc = "Toggle Break",
        }, -- step over
        {
            mode = "n",
            key = {"<leader>", "d", "o"},
            action = ":lua require'dap'.step_over()<cr>",
            desc = string.format("%-15s", "Step Over") .. "F10",
        }, {
            mode = "n",
            key = {"<F10>"},
            action = ":lua require'dap'.step_over()<cr>",
            desc = "Step Over",
        }, -- step into
        {
            mode = "n",
            key = {"<leader>", "d", "i"},
            action = ":lua require'dap'.step_into()<cr>",
            desc = string.format("%-15s", "Step Into") .. "F11",
        }, {
            mode = "n",
            key = {"<F11>"},
            action = ":lua require'dap'.step_into()<cr>",
            desc = "Step Into",
        }, -- step out
        {
            mode = "n",
            key = {"<leader>", "d", "O"},
            action = ":lua require'dap'.step_out()<cr>",
            desc = string.format("%-15s", "Step Out") .. "F12",
        }, {
            mode = "n",
            key = {"<F12>"},
            action = ":lua require'dap'.step_out()<cr>",
            desc = "Step Out",
        }, {
            mode = "n",
            key = {"<leader>", "d", "r"},
            action = ":lua require'dap'.repl.open()<cr>",
            desc = "Repl Open",
        }
    }
}

return plugin
