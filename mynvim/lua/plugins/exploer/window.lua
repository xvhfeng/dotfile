local plugin = {}

plugin.core = {only_keymapping}

plugin.mapping = {

    keys = { {
        mode = "n",
        key = {"<Leader>", "w", "x"},
        action = '<c-w>x',
        short_desc = "change context in the window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "r"},
        action = '<c-w>r',
        short_desc = "change window context"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "c"},
        action = '<c-w>c',
        short_desc = "Close current window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "J"},
        action = '<c-w>J',
        short_desc = "Change The Bottom Window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "K"},
        action = '<c-w>K',
        short_desc = "Change The Top Window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "H"},
        action = '<c-w>H',
        short_desc = "Change The Leftest Window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "L"},
        action = '<c-w>L',
        short_desc = "Change The Rightest Window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "="},
        action = '<c-w>=',
        short_desc = "Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", ","},
        action = ":vertical resize -10<CR>",
        short_desc = "Left Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "."},
        action = ":vertical resize +10<CR>",
        short_desc = "Right Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", ";"},
        action = ":resize +10<CR>",
        short_desc = "Up Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "'"},
        action = ":resize -10<CR>",
        short_desc = "Down Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "'"},
        action = ":resize -10<CR>",
        short_desc = "Down Resize window"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "["},
        action = '<c-w>t<c-w>K',
        short_desc = "change window  vertically to horizonally"
    }, {
        mode = "n",
        key = {"<Leader>", "w", "]"},
        action = '<c-w>t<c-w>H',
        short_desc = "change window horizonally to vertically"
    }, {
        mode = "n",
        key = {"<leader>", "x"},
        action = ':close<cr>',
        short_desc = "Close Current Window"
    }, {
        mode = "n",
        key = {"<Leader>", "[", "t"},
        action = '<ESC>:split term://bash<cr>',
        short_desc = "Split window and open term"
    }, {
        mode = "n",
        key = {"<Leader>", "]", "t"},
        action = '<ESC>:vsplit term://bash<cr>',
        short_desc = "Split window and open term"
    }, -- quickfix
    {
        mode = "n",
        key = {"<leader>", "q", "c"},
        action = ':cclose<cr>',
        short_desc = "QuickFix Close"
    }, {
        mode = "n",
        key = {"<leader>", "q", "o"},
        action = ':copen<cr>',
        short_desc = "QuickFix Open"
    }, {
        mode = "n",
        key = {"<leader>", "q", "p"},
        action = ':cprevious<cr>',
        short_desc = "QuickFix Previous Item"
    }, {
        mode = "n",
        key = {"<leader>", "q", "n"},
        action = ':cnext<cr>',
        short_desc = "QuickFix Next Item"
    }}
}

return plugin