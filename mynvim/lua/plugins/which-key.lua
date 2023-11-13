local plugin = {}

plugin.core = {
    "folke/which-key.nvim",
    config = function()
        require("which-key").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below

            plugins = {
                marks = true, -- shows a list of your marks on ' and `
                registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
                spelling = {
                    enabled = false, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                    suggestions = 20 -- how many suggestions should be shown in the list?
                },
                -- the presets plugin, adds help for a bunch of default keybindings in Neovim
                -- No actual key bindings are created
                presets = {
                    operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
                    motions = true, -- adds help for motions
                    text_objects = true, -- help for text objects triggered after entering an operator
                    windows = true, -- default bindings on <c-w>
                    nav = true, -- misc bindings to work with windows
                    z = true, -- bindings for folds, spelling and others prefixed with z
                    g = true -- bindings for prefixed with g
                }
            },
            -- add operators that will trigger motion and text object completion
            -- to enable all native operators, set the preset / operators plugin above
            operators = {
                gc = "Comments"
            },
            key_labels = {
                -- override the label used to display some keys. It doesn't effect WK in any other way.
                -- For example:
                ["<space>"] = "SPC",
                ["<SPACE>"] = "SPC",
                ["<Space>"] = "SPC",
                ["<cr>"] = "RET",
                ["<CR>"] = "RET",
                ["<Cr>"] = "RET",
                ["<tab>"] = "TAB",
                ["<TAB>"] = "TAB",
                ["<Tab>"] = "TAB",
            },
            icons = {
                breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                separator = "➜", -- symbol used between a key and it's label
                group = "+" -- symbol prepended to a group
            },
            popup_mappings = {
                scroll_down = '<c-n>', -- binding to scroll down inside the popup
                scroll_up = '<c-p>' -- binding to scroll up inside the popup
            },
            window = {
                border = "none", -- none, single, double, shadow
                position = "bottom", -- bottom, top
                margin = {1, 0, 1, 0}, -- extra window margin [top, right, bottom, left]
                padding = {2, 2, 2, 2}, -- extra window padding [top, right, bottom, left]
                winblend = 0
            },
            layout = {
                height = {
                    min = 4,
                    max = 25
                }, -- min and max height of the columns
                width = {
                    min = 20,
                    max = 50
                }, -- min and max width of the columns
                spacing = 3, -- spacing between columns
                align = "left" -- align columns left, center or right
            },
            ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
            hidden = {"<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "}, -- hide mapping boilerplate
            show_help = true, -- show help message on the command line when the popup is visible
            show_keys = true, -- show the currently pressed key and its label as a message in the command line
            -- triggers = "auto", -- automatically setup triggers
            triggers = {"<leader>"}, -- or specify a list manually
            triggers_blacklist = {
                -- list of mode / prefixes that should never be hooked by WhichKey
                -- this is mostly relevant for key maps that start with a native binding
                -- most people should not need to change this
                i = {"j", "k"},
                v = {"j", "k"},
            },
            triggers_nowait = { "<leader>" },
            -- disable the WhichKey popup for certain buf types and file types.
            -- Disabled by deafult for Telescope
            disable = {
                buftypes = {},
                filetypes = { "TelescopePrompt" }
            }
        }
    end
}

return plugin

