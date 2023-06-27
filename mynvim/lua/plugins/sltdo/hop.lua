local plugin = {}

plugin.core = {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    -- you can configure Hop the way you like here; see <cmd>h hop-config
    config = function()
        require'hop'.setup {
            keys = 'etovxqpdygfblzhckisuran'
        }
    end
}

plugin.mapping = {
    keymaps = {{
        mode = "n",
        key = "ff",
        action = "<cmd>HopWordAC<CR>",
        desc = "Goto word after current word"
    }, {
            mode = "n",
            key = "fb",
            action = "<cmd>HopWordBC<CR>",
            desc = "Goto word before current word"
        }, {
            mode = "n",
            key = "fl",
            action = "<cmd>HopWordCurrentLineAC<CR>",
            desc = "Goto word after in current line"
        }, {
            mode = "n",
            key = "fh",
            action = "<cmd>HopWordCurrentLineBC<CR>",
            desc = "Goto word before in current line"
        }, {
            mode = "n",
            key = "gl",
            action = "<cmd>HopLineStartAC<CR>",
            desc = "Goto line after current line"
        }, {
            mode = "n",
            key = "gh",
            action = "<cmd>HopLineStartBC<CR>",
            desc = "Goto line before current line"
        }}
}

return plugin

