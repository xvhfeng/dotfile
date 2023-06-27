local plugin = {}

plugin.core = {only_keymapping}

plugin.mapping = {
    keymaps = {
        {mode = "n", key = "E", action = "el", desc = "Move the word tail"},
        {mode = "n", key = "B", action = "Bh", desc = "Move to word head"},
        {mode = "i", key = "<C-h>", action = '<BS>', desc = "Delete Prior Char"},
        {mode = "i", key = "<C-d>", action = '<Del>', desc = "Delete Next Char"},
        {mode = "i", key = "<C-b>", action = '<Left>', desc = "Go Left"},
        {mode = "i", key = "<C-f>", action = '<Right>', desc = "Go Right"}, 
        { mode = "i", key = "<C-a>", action = '<ESC>^i', desc = "Go To The Head" },
        { mode = "i", key = "<C-e>", action = '<ESC>$a', desc = "Go To The Tail" },
        {mode = "i", key = "<C-n>", action = '<Down>', desc = "Move Down"},
        {mode = "i", key = "<C-p>", action = '<Up>', desc = "Move up"},
        { mode = "i", key = "<C-v>", action = '<PageDown>', desc = "Move PageDown" },
        {mode = "i", key = "<C-u>", action = '<PageUp>', desc = "Move PageUp"}, 
        { mode = "n", key = "[,", action = '<c-O>', desc = "JumpTo Last Postion" },
        { mode = "n", key = "[.", action = '<c-I>', desc = "jumpTo Next" },
        { mode = "n", key = "j", action = 'gj', desc = "SomeAs j In Long Line"} ,
        { mode = "n", key = "k", action = 'gk', desc = "SomeAs k In Long Line" }
    }
}

--[==[
"``"在跳转时会精确到列，
"''"不会回到跳转时光标所在的那一列，而是把光标放在第一个非空白字符上。

如果想回到更老的跳转位置，使用命令"CTRL-O"；与它相对应的，是"CTRL-I"，它跳转到更新的跳转位置(:help CTRL-O和:help CTRL-I)。这两个命令前面可以加数字来表示倍数。

使用命令":jumps"可以查看跳转表(:help :jumps)。    
--]==]

return plugin
