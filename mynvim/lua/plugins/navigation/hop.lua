local plugin = {}

plugin.core = {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    -- you can configure Hop the way you like here; see :h hop-config
    config = function()
        require'hop'.setup {
            keys = 'etovxqpdygfblzhckisuran'
        }
    end
}

plugin.mapping = {
    tags = {{
        key = "<leader>nw",
        desc = "+ Move by Word"
    }, {
        key = "<leader>nl",
        desc = "+ Move by Line"
    }},
    keys = {{
        mode = "n",
        key = {"<leader>", "n", "w", "l"},
        action = ":HopWordAC<CR>",
        short_desc = "Goto word after current word"
    }, {
        mode = "n",
        key = {"<leader>", "n", "w", "h"},
        action = ":HopWordBC<CR>",
        short_desc = "Goto word before current word"
    }, {
        mode = "n",
        key = {"<leader>", "n", "w", "L"},
        action = ":HopWordCurrentLineAC<CR>",
        short_desc = "Goto word after in current line"
    }, {
        mode = "n",
        key = {"<leader>", "n", "w", "H"},
        action = ":HopWordCurrentLineBC<CR>",
        short_desc = "Goto word before in current line"
    }, {
        mode = "n",
        key = {"<leader>", "n", "l", "l"},
        action = ":HopLineStartAC<CR>",
        short_desc = "Goto line after current line"
    }, {
        mode = "n",
        key = {"<leader>", "n", "l", "h"},
        action = ":HopLineStartBC<CR>",
        short_desc = "Goto line before current line"
    }}

}

return plugin

