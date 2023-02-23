local plugin = {}

plugin.core = {only_keymapping}

plugin.mapping = function()
    vim.cmd [[

    function! MoveToPrevTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
    return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() != 1
    close!
    if l:tab_nr == tabpagenr('$')
    tabprev
    endif
    sp
    else
    close!
    exe "0tabnew"
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
    endfunc

    function! MoveToNextTab()
    "there is only one window
    if tabpagenr('$') == 1 && winnr('$') == 1
    return
    endif
    "preparing new window
    let l:tab_nr = tabpagenr('$')
    let l:cur_buf = bufnr('%')
    if tabpagenr() < tab_nr
    close!
    if l:tab_nr == tabpagenr('$')
    tabnext
    endif
    sp
    else
    close!
    tabnew
    endif
    "opening current buffer in new window
    exe "b".l:cur_buf
    endfunc
   " nnoremap mt :call MoveToNextTab()<cr>
   " nnoremap mT :call MoveToPrevTab()<cr>

    ]]

    local mappings = require('core.keymapping')

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "s"},
        action = ':split<cr>',
        short_desc = "Split Window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "v"},
        action = ':vsplit<cr>',
        short_desc = "Vertical Split Window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "o"},
        action = ':only<cr>',
        short_desc = "Only Reserve Current Window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "x"},
        action = '<c-w>x',
        short_desc = "change context in the window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "r"},
        action = '<c-w>r',
        short_desc = "change window context"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "n"},
        action = '<c-w><c-w>',
        short_desc = "Goto Next Window"
    })
    mappings.register({
        mode = "n",
        key = {"w", "j"},
        action = '<c-w><c-j>',
        short_desc = "Goto The Down Window"

    })
    mappings.register({
        mode = "n",
        key = { "w", "k"},
        action = '<c-w><c-k>',
        short_desc = "Goto The Above Window"
    })
    mappings.register({
        mode = "n",
        key = { "w", "h"},
        action = '<c-w><c-h>',
        short_desc = "Goto The Left Window"
    })
    mappings.register({
        mode = "n",
        key = { "w", "l"},
        action = '<c-w><c-l>',
        short_desc = "Goto The Right Window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "c"},
        action = '<c-w>c',
        short_desc = "Close current window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "J"},
        action = '<c-w>J',
        short_desc = "Change The Bottom Window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "K"},
        action = '<c-w>K',
        short_desc = "Change The Top Window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "H"},
        action = '<c-w>H',
        short_desc = "Change The Leftest Window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "L"},
        action = '<c-w>L',
        short_desc = "Change The Rightest Window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "="},
        action = '<c-w>=',
        short_desc = "Resize window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", ","},
        action = ":vertical resize -10<CR>",
        short_desc = "Left Resize window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "."},
        action = ":vertical resize +10<CR>",
        short_desc = "Right Resize window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", ";"},
        action = ":resize +10<CR>",
        short_desc = "Up Resize window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "'"},
        action = ":resize -10<CR>",
        short_desc = "Down Resize window"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "'"},
        action = ":resize -10<CR>",
        short_desc = "Down Resize window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "["},
        action = '<c-w>t<c-w>K',
        short_desc = "change window  vertically to horizonally"
    })
    mappings.register({
        mode = "n",
        key = {"<Leader>", "w", "]"},
        action = '<c-w>t<c-w>H',
        short_desc = "change window horizonally to vertically"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "w", "J"},
        action = '<c-w><c-J>',
        short_desc = "Goto The Bottom Window"
    })
    mappings.register({
        mode = "n",
        key = {"<leader>", "w", "K"},
        action = '<c-w><c-K>',
        short_desc = "Goto The Top Window"
    })
    mappings.register({
        mode = "n",
        key = {"<leader>", "w", "H"},
        action = '<c-w><c-H>',
        short_desc = "Goto The Leftest Window"
    })
    mappings.register({
        mode = "n",
        key = {"<leader>", "w", "L"},
        action = '<c-w><c-L>',
        short_desc = "Goto The Rightest Window"
    })

    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"<A-a>"},
        action = '<esc>:wincmd h<cr>',
        short_desc = "<alt-h>Goto Left Window"
    })
    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"<A-d>"},
        action = '<esc>:wincmd l<cr>',
        short_desc = "<alt-l>Goto Right Window"
    })
    --[[
    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"<A-w>"},
        action = '<esc>:wincmd k<cr>',
        short_desc = "<alt-k>Goto Above Window"
    })
    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"<A-j>"},
        action = '<esc>:wincmd j<cr>',
        short_desc = "<alt-j>Goto Below Window"
    })
    --]]
    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"]", "b"},
        action = '<esc>:bnext<cr>',
        short_desc = "<alt-f>Go to Next Buffer"
    })
    mappings.register({
        mode = {"n", "v", "i", "t"},
        key = {"[", "b"},
        action = '<esc>:bprevious<cr>',
        short_desc = "<alt-b>Go to Previous Buffer"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "x"},
        action = ':close<cr>',
        short_desc = "Close Current Window"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "[", "t"},
        action = '<ESC>:split term://bash<cr>',
        short_desc = "Split window and open term"
    })

    mappings.register({
        mode = "n",
        key = {"<Leader>", "]", "t"},
        action = '<ESC>:vsplit term://bash<cr>',
        short_desc = "Split window and open term"
    })

    -- quickfix
    mappings.register({
        mode = "n",
        key = {"<leader>", "q", "c"},
        action = ':cclose<cr>',
        short_desc = "QuickFix Close"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "q", "o"},
        action = ':copen<cr>',
        short_desc = "QuickFix Open"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "q", "p"},
        action = ':cprevious<cr>',
        short_desc = "QuickFix Previous Item"
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "q", "n"},
        action = ':cnext<cr>',
        short_desc = "QuickFix Next Item"
    })

end

return plugin
