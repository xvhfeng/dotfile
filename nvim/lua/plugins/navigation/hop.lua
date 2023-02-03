local plugin = {}

plugin.core = {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
        -- you can configure Hop the way you like here; see :h hop-config
    require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
}


plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.add_mapping_prefix("<leader>nw", {
        name = "+ Move by Word"
    })
    mappings.add_mapping_prefix("<leader>nl", {
        name = "+ Move by Line"
    })

    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"w","l"},
        action = ":HopWordAC<CR>",
        short_desc = "Goto word after current word",
        silent = true
    })
    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"w","h"},
        action = ":HopWordBC<CR>",
        short_desc = "Goto word before current word",
        silent = true
    })

    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"w","L"},
        action = ":HopWordCurrentLineAC<CR>",
        short_desc = "Goto word after in current line",
        silent = true
    })
    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"w","H"},
        action = ":HopWordCurrentLineBC<CR>",
        short_desc = "Goto word before in current line",
        silent = true
    })
    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"l","l"},
        action = ":HopLineStartAC<CR>",
        short_desc = "Goto line after current line",
        silent = true
    })
    mappings.register({ 
        mode = "n",
        key = { "<leader>", "n" ,"l","h"},
        action = ":HopLineStartBC<CR>",
        short_desc = "Goto line before current line",
        silent = true
    })
end

return plugin

