local plugin = {}

plugin.core = {
    "kevinhwang91/nvim-hlslens",
    config = function()
        require('hlslens').setup()
    end
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"n"},
        action = [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]]
    }, {
        mode = "n",
        key = {"N"},
        action = [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]]
    }, {
        mode = "n",
        key = {"*"},
        action = [[*<Cmd>lua require('hlslens').start()<CR>]]
    }, {
        mode = "n",
        key = {"#"},
        action = [[#<Cmd>lua require('hlslens').start()<CR>]]
    }, {
        mode = "n",
        key = {"g", "*"},
        action = [[g*<Cmd>lua require('hlslens').start()<CR>]]
    }, {
        mode = "n",
        key = {"g", "#"},
        action = [[g#<Cmd>lua require('hlslens').start()<CR>]]
    }}
}

return plugin
