local plugin = {}


plugin.core = {only_keymapping}

plugin.mapping = {
    tags = {{
        key = "<leader>ed",
        desc = "+ Deleting in line"
    }, {
            key = "<leader>eu",
            desc = "+ Lower"
        }, {
            key = "<leader>eU",
            desc = "+ Super"
        }, {
            key = "<leader>ef",
            desc = "+ Formating"
        }},
    keys = {{
        mode = "n",
        key = {"<leader>", "e", "d", "e"},
        action = 'd$',
        short_desc = "Delete To The End",
    }, {
            mode = "n",
            key = {"<leader>", "e", "d", "b"},
            action = 'd^',
            short_desc = "Delete To The Begin"
        }, {
            mode = "n",
            key = {"<Leader>", "e", "f", "t"},
            action = '<ESC>=a{',
            short_desc = "format code style"
        }, {
            mode = "n",
            key = {"<leader>", "e", "U", "w"},
            action = 'mQviwU`Q',
            short_desc = "Upper the word"
        }, {
            mode = "n",
            key = {"<leader>", "e", "u", "w"},
            action = 'mQviwu`Q',
            short_desc = "Lower the word"
        }, {
            mode = "n",
            key = {"<leader>", "e", "U", "f"},
            action = 'mQgewvU`Q',
            short_desc = "Upper the first char of word"
        }, {
            mode = "n",
            key = {"<leader>", "e", "u", "f"},
            action = 'mQgewvu`Q',
            short_desc = "Lower the first char of word"
        }, {
            mode = "v",
            key = {"<c-j>"},
            action = ":move '>+1<CR>gv-gv",
            s,
            hort_desc = "move selected ranger up"
        }, {
            mode = "v",
            key = {"<c-k>"},
            action = ":move '<-2<CR>gv-gv",
            short_desc = "move selected range down"
        }, {
            mode = "n",
            key = {"<c-j>"},
            action = ":<c-u>execute 'move +'. v:count1<cr>",
            short_desc = "move currnet line up"
        }, {
            mode = "n",
            key = {"<c-k>"},
            action = ":<c-u>execute 'move -1-'. v:count1<cr>",
            short_desc = "move currnet line down"
        }, {
            mode = "n",
            key = {"j"},
            action = "gj",
            noremap = true,
            short_desc = "the same as j when long line"
        }, {
            mode = "n",
            key = {"k"},
            action = "gk",
            noremap = true,
            short_desc = "the same as k when long line"
        }, {
            mode = "n",
            key = {"E"},
            action = "el",
            short_desc = "Move the word tail"
        }, {
            mode = "n",
            key = {"B"},
            action = "Bh",
            short_desc = "Move to word head"
        }, {
            mode = "n",
            key = {"K"},
            action = "i<CR><ESC>",
            short_desc = "Split current line to two line"
        }, {
            mode = "n",
            key = {"[", "<SPACE>"},
            action = "::<c-u>put! =repeat(nr2char(10), v:count1)<cr>",
            short_desc = "insert blank line up"
        }, {
            mode = "n",
            key = {"]", "<SPACE>"},
            action = ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",
            short_desc = "insert blank line down"
        }, -- emacs key binding for insert mode
        {
            mode = "i",
            key = {"<C-w>"},
            action = '<C-[>diwa',
            short_desc = "Delete Prior Word"
        }, {
            mode = "i",
            key = {"<C-h>"},
            action = '<BS>',
            short_desc = "Delete Prior Char"
        }, {
            mode = "i",
            key = {"<C-d>"},
            action = '<Del>',
            short_desc = "Delete Next Char"
        }, {
            mode = "i",
            key = {"<C-b>"},
            action = '<Left>',
            short_desc = "Go Left"
        }, {
            mode = "i",
            key = {"<C-f>"},
            action = '<Right>',
            short_desc = "Go Right"
        }, {
            mode = "i",
            key = {"<C-a>"},
            action = '<ESC>^i',
            short_desc = "Go To The Begin and Insert"
        }, {
            mode = "i",
            key = {"<C-e>"},
            action = '<ESC>$a',
            short_desc = "Go To The End and Append"
        }, {
            mode = "i",
            key = {"<C-n>"},
            action = '<Down>',
            short_desc = "Move Down"
        }, {
            mode = "i",
            key = {"<C-p>"},
            action = '<Up>',
            short_desc = "Move up"
        }, {
            mode = "i",
            key = {"<C-v>"},
            action = '<PageDown>',
            short_desc = "Move PageDown"
        }, {
            mode = "i",
            key = {"<C-u>"},
            action = '<PageUp>',
            short_desc = "Move PageUp"
        }, --[===[
zc	关闭当前打开的折叠
zo	打开当前的折叠
zm	关闭所有折叠
zM	关闭所有折叠及其嵌套的折叠
zr	打开所有折叠
zR	打开所有折叠及其嵌套的折叠
zd	删除当前折叠
zE	删除所有折叠
zj	移动至下一个折叠
zk	移动至上一个折叠

zn	禁用折叠
zN	启用折叠

--]===] {
            mode = "n",
            key = {"z", "j"},
            action = 'zf%',
            short_desc = "folding"
        }, {
            mode = "n",
            key = {"<leader>","f","B"},
            action = 'gg=G',
            short_desc = "Format(Except C/C++ Lua)"
        }
        -- , {
        --    mode = "n",
        --   key = {"<c-a>"},
        --  action = 'ggvG$',
        -- short_desc = "Select All File"
        --}
    }
}

return plugin
