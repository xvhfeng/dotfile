local plugin = {}

plugin.core = {
    'stevearc/aerial.nvim',
    -- opts = {},
    -- Optional dependencies
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },

    --event = "User AstroFile",
    opts = {
        attach_mode = "global",
        backends = { "lsp", "treesitter", "markdown", "man" },
        -- disable_max_lines = vim.g.max_file.lines,
        -- disable_max_size = vim.g.max_file.size,
        layout = { min_width = 28 },
        show_guides = true,
        filter_kind = false,
        guides = {
            mid_item = "├ ",
            last_item = "└ ",
            nested_top = "│ ",
            whitespace = "  ",
        },
        keymaps = {
            ["[y"] = "actions.prev",
            ["]y"] = "actions.next",
            ["[Y"] = "actions.prev_up",
            ["]Y"] = "actions.next_up",
            ["{"] = false,
            ["}"] = false,
            ["[["] = false,
            ["]]"] = false,
        },
    },

}

plugin.mapping = {
    keymaps = {
        {
            tag = {
                key = "<leader>ls",
                name = "Outline"
            },
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>lso",
                    action = "<cmd>AerialToggle<CR>",
                    desc = "Aerial Outline"
                }
            }
        }
    }
}

return plugin
