local plugin = {}

plugin.core = {only_keymapping = true}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "wh",
            action = '<c-w>h',
            desc = "Move To Left Window"
        },
        {
            mode = "n",
            key = "<c-'>",
            action = '<c-w><',
            desc = "Move To Left Window"
        },
        {
            mode = "n",
            key = "<c-;>",
            action = '<c-w>>',
            desc = "Move To Left Window"
        },
        {
            mode = "n",
            key = "wl",
            action = '<c-w>l',
            desc = "Move To Right Window"
        }, {
            mode = "n",
            key = "wj",
            action = '<c-w>j',
            desc = "Move To Below Window"
        },
        {
            mode = "n",
            key = "wk",
            action = '<c-w>k',
            desc = "Move To Top Window"
        },
        {
            mode = "n",
            key = "w=",
            action = '<c-w>=',
            desc = "Resize window"
        },
      --[[
      --]]
      {
            mode = "n",
            key = "[w",
            action = '<c-w>t<c-w>K',
            desc = "change window  vertically to horizonally"
        }, {
            mode = "n",
            key = "]w",
            action = '<c-w>t<c-w>H',
            desc = "change window horizonally to vertically"
        }, {
            mode = "n",
            key = "<leader>x",
            action = ':close<cr>',
            desc = "Close Current Window"
        }, {
            mode = "n",
            key = "[t",
            action = '<ESC>:split term://bash<cr>',
            desc = "Split window and open term"
        }, {
            mode = "n",
            key = "]t",
            action = '<ESC>:vsplit term://bash<cr>',
            desc = "Split window and open term"
        }, -- quickfix
        {
            mode = "n",
            key = "<leader>qc",
            action = ':cclose<cr>',
            desc = "QuickFix Close"
        }, {
            mode = "n",
            key = "<leader>qo",
            action = ':copen<cr>',
            desc = "QuickFix Open"
        },

        {
            mode = "c",
            key = "<c-p>",
            action = '<Up>',
            desc = "QuickFix Previous Item"
        }, {
            mode = "c",
            key = "<c-n>",
            action = '<Down>',
            desc = "QuickFix Next Item"
        }

    }
}

return plugin
