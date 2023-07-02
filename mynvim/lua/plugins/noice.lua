local plugin = {}

plugin.core = {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        -- add any options here
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
        "MunifTanjim/nui.nvim",
        -- OPTIONAL:
        --   `nvim-notify` is only needed, if you want to use the notification view.
        --   If not available, we use `mini` as the fallback
--        "rcarriga/nvim-notify",
    },

    config = function()
        require("noice").setup({
            cmdline = {
                format = {
                    cmdline = { icon = ">" },
                    search_down = { icon = "🔍⌄" },
                    search_up = { icon = "🔍⌃" },
                    filter = { icon = "$" },
                    lua = { icon = "☾" },
                    help = { icon = "?" },
                },
            },

            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },

            presets = {
                bottom_search = false, -- use a classic bottom cmdline for search
                -- command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = true, -- add a border to hover docs and signature help
                command_palette = {
                    views = {
                        cmdline_popup = {
                            position = {
                                row = 20,
                                col = "50%",
                            },
                            size = {
                                min_width = 60,
                                width = "auto",
                                height = "auto",
                            },
                        },
                        popupmenu = {
                            enabled = true,
                            backend = "nui",
                            relative = "editor",
                            position = {
                                row = 23,
                                col = "50%",
                            },
                            size = {
                                width = 60,
                                height = "auto",
                                max_height = 15,
                            },
                            border = {
                                style = "rounded",
                                padding = { 0, 1 },
                            },
                            win_options = {
                                winhighlight = { Normal = "Normal", FloatBorder = "NoiceCmdlinePopupBorder" },
                            },
                        },
                    },
                },
            },
        })
    end
}

--[[   
local OpenCmdLine = function()
    require("noice").redirect(vim.fn.getcmdline())
    end

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<c>-x",
            action ="<cmd>lua OpenCmdLine()<cr>", 
            desc = "Redirect Cmdline"
        }
    }
}
--]]

return plugin
