local plugin = {}

plugin.core = {only_keymapping = true}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<c-x><c-w>",
            action = 'mQviwU`Q',
            desc = "Upper the word"
        },
        {
            mode = "n",
            key = "<c-x><c-u",
            action = 'mQviwu`Q',
            desc = "Lower the word"
        }, {
            mode = "n",
            key = "<c-x><c-m>",
            action = 'mQgewvU`Q',
            desc = "Upper the first char of word"
        }, {
            mode = "n",
            key = "<c-x><c-n>",
            action = 'mQgewvu`Q',
            desc = "Lower the first char of word"
        }, {
            mode = "v",
            key = "<c-j>",
            action = ":move '>+1<CR>gv-gv",
            desc = "move selected ranger up"
        }, {
            mode = "v",
            key = "<c-k>",
            action = ":move '<-2<CR>gv-gv",
            desc = "move selected range down"
        }, {
            mode = "n",
            key = "<c-j>",
            action = ":<c-u>execute 'move +'. v:count1<cr>",
            desc = "move currnet line up"
        }, {
            mode = "n",
            key = "<c-k>",
            action = ":<c-u>execute 'move -1-'. v:count1<cr>",
            desc = "move currnet line down"
        },

        {
            mode = "n",
            key = "K",
            action = "i<CR><ESC>",
            desc = "Split current line to two line"
        }, {
            mode = "n",
            key = "[<SPACE>",
            action = "::<c-u>put! =repeat(nr2char(10), v:count1)<cr>",
            desc = "insert blank line up"
        }, {
            mode = "n",
            key = "]<SPACE>",
            action = ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",
            desc = "insert blank line down"
        }, -- emacs key binding for insert mode

        {
            mode = "i",
            key = "<C-w>",
            action = '<C-[>diwa',
            desc = "Delete Prior Word"
        },
        --[===[
zc  关闭当前打开的折叠
zo  打开当前的折叠
zm  关闭所有折叠
zM  关闭所有折叠及其嵌套的折叠
zr  打开所有折叠
zR  打开所有折叠及其嵌套的折叠
zd  删除当前折叠
zE  删除所有折叠
zj  移动至下一个折叠
zk  移动至上一个折叠

zn  禁用折叠
zN  启用折叠

--]===]
        -- {mode = "n", key = "zj", action = 'zf%', desc = "folding"},
        {mode = {"n", "i"}, key = "<c-s>", action = '<cmd>w<cr>', desc = "Save"},
        {mode = "n", key = "<c-a>", action = 'gg^vG$', desc = "Select All File"},
        {
            mode = "n",
            key = "<c-l>",
            action = '^v$',
            desc = "Select Currnet Line"
        }
    }
}

return plugin
