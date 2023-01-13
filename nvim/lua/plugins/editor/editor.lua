local plugin = {}

plugin.core = {only_keymapping}

plugin.mapping = function()
    local mappings = require('core.keymapping')

    mappings.add_mapping_prefix("<leader>ed", {
        name = "+ Deleting in line"
    })

    mappings.add_mapping_prefix("<leader>eu", {
        name = "+ Lower"
    })

    mappings.add_mapping_prefix("<leader>eU", {
        name = "+ Super"
    })

    mappings.add_mapping_prefix("<leader>ef", {
        name = "+ Formating"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "d", "e"},
        action = 'd$',
        short_desc = "Delete To The End",
        noremap = true,
    })
    
    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "d", "b"},
        action = 'd^',
        short_desc = "Delete To The Begin"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "e", "f", "t"},
        action = '<ESC>=a{',
        short_desc = "format code style"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "U", "w"},
        action = 'mQviwU`Q',
        short_desc = "Upper the word"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "u", "w"},
        action = 'mQviwu`Q',
        short_desc = "Lower the word"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "U", "f"},
        action = 'mQgewvU`Q',
        short_desc = "Upper the first char of word"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "e", "u", "f"},
        action = 'mQgewvu`Q',
        short_desc = "Lower the first char of word"
    })

    mappings.register({
        mode = "v",
        key = {"J"},
        action = ":move '>+1<CR>gv-gv",
        short_desc = "move selected ranger up"
    })

    mappings.register({
        mode = "v",
        key = {"K"},
        action = ":move '<-2<CR>gv-gv",
        short_desc = "move selected range down"
    })

    mappings.register({
        mode = "n",
        key = {"J"},
        action = ":<c-u>execute 'move +'. v:count1<cr>",
        short_desc = "move currnet line up"
    })

    mappings.register({
        mode = "n",
        key = {"K"},
        action = ":<c-u>execute 'move -1-'. v:count1<cr>",
        short_desc = "move currnet line down"
    })

    mappings.register({
        mode = "n",
        key = {"[", "<SPACE>"},
        action = "::<c-u>put! =repeat(nr2char(10), v:count1)<cr>",
        short_desc = "insert blank line up"
    })

    mappings.register({
        mode = "n",
        key = {"]", "<SPACE>"},
        action = ":<c-u>put =repeat(nr2char(10), v:count1)<cr>",
        short_desc = "insert blank line down"
    })

    -- emacs key binding for insert mode
    mappings.register({
        mode = "i",
        key = {"<C-w>"},
        action = '<C-[>diwa',
        short_desc = "Delete Prior Word"
    })
    mappings.register({
        mode = "i",
        key = {"<C-h>"},
        action = '<BS>',
        short_desc = "Delete Prior Char"
    })
    mappings.register({
        mode = "i",
        key = {"<C-d>"},
        action = '<Del>',
        short_desc = "Delete Next Char"
    })
    mappings.register({
        mode = "i",
        key = {"<C-b>"},
        action = '<Left>',
        short_desc = "Go Left"
    })
    mappings.register({
        mode = "i",
        key = {"<C-f>"},
        action = '<Right>',
        short_desc = "Go Right"
    })
    mappings.register({
        mode = "i",
        key = {"<C-a>"},
        action = '<ESC>^i',
        short_desc = "Go To The Begin and Insert"
    })
    mappings.register({
        mode = "i",
        key = {"<C-e>"},
        action = '<ESC>$a',
        short_desc = "Go To The End and Append"
    })

    mappings.register({
        mode = "i",
        key = {"<C-n>"},
        action = '<Down>',
        short_desc = "Move Down"
    })

    mappings.register({
        mode = "i",
        key = {"<C-p>"},
        action = '<Up>',
        short_desc = "Move up"
    })

    mappings.register({
        mode = "i",
        key = {"<C-v>"},
        action = '<PageDown>',
        short_desc = "Move PageDown"
    })

    mappings.register({
        mode = "i",
        key = {"<C-u>"},
        action = '<PageUp>',
        short_desc = "Move PageUp"
    })

    --[===[
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

--]===]
    mappings.register({
        mode = "n",
        key = {"z", "f"},
        action = 'zf%',
        short_desc = "folding"
    })

    mappings.register({
        mode = "n",
        key = {"<SPACE>"},
        action = 'za',
        short_desc = "toggle folding"
    })
end

return plugin
